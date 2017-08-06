#frozen_string_literal: true
require "minitest/autorun"
require "net/https"
require "uri"
require "openssl"

class TestSslCacerts < Minitest::Test
  EXTERNAL_HTTPS = "https://torproject.org"

  def test_https_external
    uri = URI(EXTERNAL_HTTPS)
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |https|
      https.head('/').code
    end
    assert_equal("302", res)
  end

  def test_generate_certs
    ks = pki
    assert ks.server_cert.verify(ks.ca_cert.public_key)

    File.write("ca_key.pem", ks.ca_key.to_pem)
    File.write("ca_cert.pem", ks.ca_cert.to_pem)
    File.write("server_key.pem", ks.server_key.to_pem)
    File.write("server_cert.pem", ks.server_cert.to_pem)
  end

  def test_ssl_connection_ipv4
    check_ssl_with_ipvX('127.0.0.1', '127.0.0.1', 4)
  end

  def test_ssl_connection_ipv6
    check_ssl_with_ipvX('::1', '::1', 6)
  end

  def check_ssl_with_ipvX(bind, host, ipvX)
    ks = pki

    server  = TCPServer.new bind, 0
    server_th = Thread.new do
      context = OpenSSL::SSL::SSLContext.new
      context.client_ca = ks.ca_cert
      context.cert = ks.server_cert
      context.key  = ks.server_key
      sserver = OpenSSL::SSL::SSLServer.new(server, context)
      ssconn = sserver.accept
      sserver.close
      server.close
      ssconn
    end

    client  = TCPSocket.new host, server.local_address.ip_port
    context = OpenSSL::SSL::SSLContext.new
    context.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
    cert_store = OpenSSL::X509::Store.new
    cert_store.add_cert ks.ca_cert
    context.cert_store = cert_store

    sclient = OpenSSL::SSL::SSLSocket.new(client, context)
    sclient.connect
    assert client.local_address.send("ipv#{ipvX}?"), "connection should be ipv#{ipvX}"
    assert server_th.value.to_io.local_address.send("ipv#{ipvX}?"), "connection should be ipv#{ipvX}"

    assert_ssl_connection_is_usable(server_th.value, sclient)
  end

  def assert_ssl_connection_is_usable(server, client)
    server_th = Thread.new do
      server.write("hello server->client")
      server.flush
      server.to_io.close_write
      res = server.read
      server.close
      server.to_io.close
      res
    end

    client.write("hello client->server")
    client.flush
    client.to_io.close_write

    assert "hello server->client", client.read
    assert "hello client->server", server_th.value

    client.close
    client.to_io.close
  end

  trap(2) do
    Thread.list.each do |th|
      puts th.backtrace
    end
    exit -1
  end

  @@keys = {}
  @@certs = {}

  def pki
    ca_cert, ca_key = create_cert("ca")
    server_cert, server_key = create_cert("server", ca_cert, ca_key)
    Struct.new(:ca_cert, :ca_key, :server_cert, :server_key)
          .new(ca_cert, ca_key, server_cert, server_key)
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
