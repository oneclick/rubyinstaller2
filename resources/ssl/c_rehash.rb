#!/usr/bin/env ruby

require 'openssl'
require 'digest/md5'

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
      delete_symlink
      Dir.glob('*.pem') do |pemfile|
        load_pem_file(pemfile).each do |cert|
          case cert
          when OpenSSL::X509::Certificate
            link_hash_cert(cert)
          when OpenSSL::X509::CRL
            link_hash_crl(cert)
          else
            STDERR.puts("WARNING: #{pemfile} does not contain a certificate or CRL: skipping") unless @silent
          end
        end
      end
    end
  end

  def delete_symlink
    Dir.entries(".").each do |entry|
      next unless /^[\da-f]+\.r{0,1}\d+$/ =~ entry
      File.unlink(entry) if FileTest.symlink?(entry) or FileTest.file?(entry)
    end
  end

  def link_hash_cert(cert)
    name_hash = hash_name(cert.subject)
    fingerprint = fingerprint(cert.to_der)
    filepath = link_hash(cert, name_hash, fingerprint) { |idx|
      "#{name_hash}.#{idx}"
    }
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
    sprintf("%x", name.hash)
  end

  def fingerprint(der)
    Digest::MD5.hexdigest(der).upcase
  end
end

if $0 == __FILE__
  dirlist = ARGV
  dirlist << '.' if dirlist.empty?
  dirlist.each do |dir|
    CHashDir.new(dir).hash_dir
  end
end
