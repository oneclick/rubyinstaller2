#!/usr/bin/env ruby

# This is a helper script to add trusted CA certificates to RubyInstaller.
# See README-SSL.md for more details.

require 'openssl'

class CHashDir
  include Enumerable

  def initialize(dirpath)
    @dirpath = dirpath
    @fingerprint_cache = @cert_cache = @crl_cache = nil
  end

  def hash_dir(silent = false)
    # ToDo: Should lock the directory...
    @silent = silent
    @fingerprint_cache = Hash.new
    @cert_cache = Hash.new
    @crl_cache = Hash.new
    do_hash_dir
  end

  def get_certs(name = nil)
    if name
      @cert_cache[hash_name(name)]
    else
      @cert_cache.values.flatten
    end
  end

  def get_crls(name = nil)
    if name
      @crl_cache[hash_name(name)]
    else
      @crl_cache.values.flatten
    end
  end

  def delete_crl(crl)
    File.unlink(crl_filename(crl))
    hash_dir(true)
  end

  def add_crl(crl)
    File.open(crl_filename(crl), "w") do |f|
      f << crl.to_pem
    end
    hash_dir(true)
  end

  def load_pem_file(filepath)
    str = File.read(filepath)
    str.scan(/-----BEGIN (?:X509 CRL|CERTIFICATE|CERTIFICATE REQUEST)-----.*?-----END (?:X509 CRL|CERTIFICATE|CERTIFICATE REQUEST)-----/m).map do |m|
      begin
        OpenSSL::X509::Certificate.new(m)
      rescue
        begin
          OpenSSL::X509::CRL.new(m)
        rescue
          begin
            OpenSSL::X509::Request.new(m)
          rescue
            nil
          end
        end
      end
    end
  end

  private

  def crl_filename(crl)
    path(hash_name(crl.issuer)) + '.pem'
  end

  def do_hash_dir
    Dir.chdir(@dirpath) do
      delete_symlink(".")

      begin
        msys = RubyInstaller::Runtime.msys2_installation
        mingw_certs = File.expand_path("../etc/ssl/certs", msys.mingw_bin_path)
        msys_bundle = File.expand_path("usr/ssl/certs/ca-bundle.crt", msys.msys_path)
      rescue RubyInstaller::Runtime::Msys2Installation::MsysNotFound
      else
        delete_symlink(mingw_certs)
        delete_from_bundle(msys_bundle)
      end

      Dir.glob('*.pem') do |pemfile|
        load_pem_file(pemfile).each do |cert|
          case cert
          when OpenSSL::X509::Certificate
            # Create hash file in rubyinstallers's ssl directory
            # This is used by builtin openssl.gem
            link_hash_cert(cert, ".")

            # Create hash file in msys2/mingw's ssl directory
            # This is used when openssl.gem is built from sources
            link_hash_cert(cert, mingw_certs) if mingw_certs

            # Create hash file in msys2/mingw's ssl directory
            # This is used by MSYS2 tools like curl and pacman
            add_to_bundle(cert, msys_bundle) if msys_bundle

          when OpenSSL::X509::CRL
            link_hash_crl(cert)
          else
            STDERR.puts("WARNING: #{pemfile} does not contain a certificate or CRL: skipping") unless @silent
          end
        end
      end
    end
  end

  def delete_symlink(hashdir)
    Dir.entries(hashdir).each do |entry|
      next unless /^[\da-f]+\.r{0,1}\d+$/ =~ entry
      epath = File.join(hashdir, entry)
      File.unlink(epath) if FileTest.symlink?(epath) or FileTest.file?(epath)
    end
  end

  def delete_from_bundle(bundle_fname)
    fc = File.read(bundle_fname)

    # Create a bak file before modification
    fname_bak = bundle_fname + ".bak-ruby"
    File.write(fname_bak, fc) unless File.exist?(fname_bak)

    # Remove all certs inserted by RubyInstaller
    fc = fc.gsub(/# RubyInstaller: [^\n]*\n-----BEGIN CERTIFICATE-----[^-]*-----END CERTIFICATE-----\n*/m, "")
    File.write(bundle_fname, fc)
  end

  def add_to_bundle(cert, bundle_fname)
    fc = File.read(bundle_fname)
    ct = <<~EOT
      # RubyInstaller: #{cert.subject}
      #{cert.to_pem}
    EOT
    fc = ct + fc
    File.write(bundle_fname, fc)
    STDOUT.puts("#{cert.subject} => #{bundle_fname}") unless @silent
  end

  def link_hash_cert(cert, hashdir)
    name_hash = hash_name(cert.subject)
    fingerprint = fingerprint(cert.to_der)
    filepath = link_hash(cert, name_hash, fingerprint) do |idx|
      File.join(hashdir, "#{name_hash}.#{idx}")
    end
    unless filepath
      unless @silent
        STDERR.puts("WARNING: Skipping duplicate certificate #{cert.subject}")
      end
    else
      (@cert_cache[name_hash] ||= []) << path(filepath)
    end
  end

  def link_hash_crl(crl)
    name_hash = hash_name(crl.issuer)
    fingerprint = fingerprint(crl.to_der)
    filepath = link_hash(cert, name_hash, fingerprint) { |idx|
      "#{name_hash}.r#{idx}"
    }
    unless filepath
      unless @silent
        STDERR.puts("WARNING: Skipping duplicate CRL #{cert.subject}")
      end
    else
      (@crl_cache[name_hash] ||= []) << path(filepath)
    end
  end

  def link_hash(cert, name, fingerprint)
    idx = 0
    filepath = nil
    while true
      filepath = yield(idx)
      break unless FileTest.symlink?(filepath) or FileTest.exist?(filepath)
      if @fingerprint_cache[filepath] == fingerprint
        return false
      end
      idx += 1
    end
    STDOUT.puts("#{cert.subject} => #{filepath}") unless @silent
    File.write(filepath, cert.to_pem)
    @fingerprint_cache[filepath] = fingerprint
    filepath
  end

  def path(filename)
    File.join(@dirpath, filename)
  end

  def hash_name(name)
    sprintf("%08x", name.hash)
  end

  def fingerprint(der)
    OpenSSL::Digest.hexdigest('MD5', der).upcase
  end
end

if $0 == __FILE__
  dirlist = ARGV
  dirlist << '.' if dirlist.empty?
  dirlist.each do |dir|
    CHashDir.new(dir).hash_dir
  end
end
