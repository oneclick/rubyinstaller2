#frozen_string_literal: true
require "minitest/autorun"
require "net/https"
require "uri"
require "openssl"

class TestSslCacerts < Minitest::Test
  EXTERNAL_HTTPS = "https://rubyinstaller.org"

  # Can we connect to a external host with our default RubyInstaller CA list?
  def test_https_external
    uri = URI(EXTERNAL_HTTPS)
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |https|
      https.head('/').code
    end
    assert_equal("200", res)
  end

  # Can we generate a valid PKI?
  def test_generate_certs
    assert pki.server_cert.verify(pki.ca_cert.public_key)
  end

  def test_ssl_connection_ipv4
    check_ssl_with_ipvX('127.0.0.1', '127.0.0.1', 4)
  end

  def test_ssl_connection_ipv6
    check_ssl_with_ipvX('::1', '::1', 6)
  end

  # Can CA certificates overwritten per SSL_CERT_FILE environment variable?
  def test_SSL_CERT_FILE
    if ENV['SSL_CERT_FILE']
      # Connect per system CA list (overwritten per SSL_CERT_FILE)
      sclient = connect_ssl_client("localhost", 23456)
      res = read_and_close_ssl(sclient, "hello client->server")
      assert_equal "hello server->client", res
    else
      server  = TCPServer.new "localhost", 23456
      server_th = Thread.new do
        sserver = run_ssl_server(server, pki)
        read_and_close_ssl(sserver, "hello server->client")
      end

      Tempfile.open(["cert", ".pem"]) do |fd|
        fd.write pki.ca_cert.to_pem
        fd.close
        ENV['SSL_CERT_FILE'] = fd.path
        cmd = ["ruby", __FILE__, "-n", __method__.to_s]
        res = IO.popen(cmd, &:read)
        assert_equal 0, $?.exitstatus, "res #{cmd.join(" ")} failed: #{res}"
        ENV.delete('SSL_CERT_FILE')
      end

      assert_equal "hello client->server", server_th.value
    end
  end

  # Can CA certificates added into C:/Ruby24/etc/ssl/certs/<hash>.0 ?
  def test_ssl_certs_dir
    certfile = "#{RbConfig::TOPDIR}/#{"etc/" if RUBY_VERSION >= "3.2"}ssl/certs/#{pki.ca_cert.subject.hash.to_s(16)}.0"
    File.write(certfile, pki.ca_cert.to_pem)

    server  = TCPServer.new "localhost", 0
    server_th = Thread.new do
      run_ssl_server(server, pki)
    end

    # Connect per system CA list (with addition of our certificate)
    sclient = connect_ssl_client("localhost", server.local_address.ip_port)
    assert_ssl_connection_is_usable(server_th.value, sclient)

    File.unlink(certfile)
  end

  def check_ssl_with_ipvX(bind, host, ipvX)
    server  = TCPServer.new bind, 0
    server_th = Thread.new do
      run_ssl_server(server, pki)
    end

    sclient = connect_ssl_client(host, server.local_address.ip_port, pki)
    assert sclient.to_io.local_address.send("ipv#{ipvX}?"), "connection should be ipv#{ipvX}"
    assert server_th.value.to_io.local_address.send("ipv#{ipvX}?"), "connection should be ipv#{ipvX}"

    assert_ssl_connection_is_usable(server_th.value, sclient)
  end

  def run_ssl_server(server, pki)
    context = OpenSSL::SSL::SSLContext.new
    context.client_ca = pki.ca_cert
    context.cert = pki.server_cert
    context.key  = pki.server_key
    sserver = OpenSSL::SSL::SSLServer.new(server, context)
    ssconn = sserver.accept
    sserver.close
    server.close
    ssconn
  end

  def connect_ssl_client(host, port, pki=nil)
    client  = TCPSocket.new host, port
    context = OpenSSL::SSL::SSLContext.new
    context.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
    if pki
      cert_store = OpenSSL::X509::Store.new
      cert_store.add_cert pki.ca_cert
    else
      cert_store = OpenSSL::X509::Store.new
      cert_store.set_default_paths
    end
    context.cert_store = cert_store

    sclient = OpenSSL::SSL::SSLSocket.new(client, context)
    sclient.connect
    sclient
  end

  def assert_ssl_connection_is_usable(server, client)
    server_th = Thread.new do
      read_and_close_ssl(server, "hello server->client")
    end

    res = read_and_close_ssl(client, "hello client->server")
    assert_equal "hello server->client", res
    assert_equal "hello client->server", server_th.value
  end

  def read_and_close_ssl(sio, msg)
    sio.puts(msg)
    sio.flush
    res = sio.gets.chomp
    sio.close
    sio.to_io.close
    res
  end

  @@keys = {}
  @@certs = {}
  @@mutex = Thread::Mutex.new

  def pki
    @@mutex.synchronize do
      ca_cert, ca_key = create_cert("ca")
      server_cert, server_key = create_cert("server", ca_cert, ca_key)
      Struct.new(:ca_cert, :ca_key, :server_cert, :server_key)
            .new(ca_cert, ca_key, server_cert, server_key)
    end
  end

  def create_cert(name, ca_cert=nil, ca_key=nil)
    key = @@keys[name] ||= OpenSSL::PKey::RSA.new 2048

    cert = @@certs[name] ||= begin
      cert = OpenSSL::X509::Certificate.new
      cert.serial = 0
      cert.version = 2
      cert.not_before = Time.now
      cert.not_after = Time.now + 86400
      cert.public_key = key.public_key

      cert_name = OpenSSL::X509::Name.parse "CN=#{name}/DC=example"
      cert.subject = cert_name

      extension_factory = OpenSSL::X509::ExtensionFactory.new nil, cert
      if ca_cert
        # already have a CA cert
        cert.issuer = ca_cert.subject
        extension_factory.issuer_certificate = ca_cert
        cert.add_extension    extension_factory.create_extension('basicConstraints', 'CA:FALSE', true)
        cert.add_extension    extension_factory.create_extension('keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature')
      else
        cert.issuer = cert_name
        extension_factory.issuer_certificate = cert
        # build a CA cert
        # This extension indicates the CA’s key may be used as a CA.
        cert.add_extension    extension_factory.create_extension('basicConstraints', 'CA:TRUE', true)
        # This extension indicates the CA’s key may be used to verify signatures on both certificates and certificate revocations.
        cert.add_extension    extension_factory.create_extension('keyUsage', 'cRLSign,keyCertSign', true)
      end
      cert.add_extension    extension_factory.create_extension('subjectKeyIdentifier', 'hash')

      # Root CA certificates are self-signed.
      cert.sign(ca_key || key, OpenSSL::Digest::SHA256.new)
      cert
    end
    [cert, key]
  end
end
