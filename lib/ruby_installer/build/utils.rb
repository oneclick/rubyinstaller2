module RubyInstaller
module Build
module Utils
  WINDOWS_CMD_SHEBANG = <<-EOT.freeze
:""||{ ""=> %q<-*- ruby -*-
@"%~dp0ruby" -x "%~f0" %*
@exit /b %ERRORLEVEL%
};{ #
bindir="${0%/*}" #
exec "$bindir/ruby" -x "$0" "$@" #
>, #
} #
EOT

  def msys_sh(cmd)
    Build.enable_msys_apps
    pwd = Dir.pwd
    sh "sh", "-lc", "cd `cygpath -u #{pwd.inspect}`; #{cmd}"
  end

  MOZILLA_CA_CSV_URI = "https://mozillacaprogram.secure.force.com/CA/IncludedCACertificateReportPEMCSV"

  def download_ssl_cacert_pem
    require 'open-uri'
    require 'csv'
    require 'openssl'
    require 'stringio'

    csv_data = OpenURI.open_uri(MOZILLA_CA_CSV_URI)

    fd = StringIO.new
    fd.write <<-EOT
##
## Bundle of CA Root Certificates
##
## Certificate data from Mozilla as of: #{Time.now.utc}
##
## This is a bundle of X.509 certificates of public Certificate Authorities (CA).
## These were automatically extracted from Mozilla's root certificates CSV file
## downloaded from:
## #{MOZILLA_CA_CSV_URI}
##
## Further information about the CA certificate list can be found:
## https://wiki.mozilla.org/CA:IncludedCAs
##
## This file is used as default CA certificate list for Ruby.
## Conversion done with rubyinstaller-build version #{RubyInstaller::Build::GEM_VERSION}.
##
EOT

    CSV.parse(csv_data, headers: true).select do |row|
      row["Trust Bits"].split(";").include?("Websites")
    end.map do |row|
      pem = row["PEM Info"]
      OpenSSL::X509::Certificate.new(pem.gsub(/\A'/,"").gsub(/'\z/,""))
    end.sort_by do |cert|
      cert.subject.to_a.sort
    end.each do |cert|
      sj = OpenSSL::X509::Name.new(cert.subject.to_a.sort).to_s
      fd.write "\n#{ sj }\n#{ "=" * sj.length }\n#{ cert.to_pem }\n"
    end

    fd.string
  end

  def remove_comments(filecontent)
    filecontent.gsub(/^##.*$/, "")
  end

  def with_env(hash)
    olds = hash.each{|k, _| [k, ENV[k.to_s]] }
    hash.each do |k, v|
      ENV[k.to_s] = v
    end
    begin
      yield
    ensure
      olds.each do |k, v|
        ENV[k.to_s] = v
      end
    end
  end

  GEM_ROOT = File.expand_path("../../../..", __FILE__)
  REWRITE_MARK = /module Build.*Use for: Build, Runtime/

  def lib_runtime_files
    spec = Gem.loaded_specs["rubyinstaller-build"]
    spec ||= Gem::Specification.load(File.join(GEM_ROOT, "rubyinstaller-build.gemspec"))
    spec.files.select do |file|
      file.match(%r{^lib/}) &&
      (!file.match(%r{^lib/ruby_installer/build}) || File.binread(ovl_expand_file(file))[REWRITE_MARK])
    end
  end

  # Scan the current and the gem root directory for files matching rel_pattern.
  #
  # All paths returned are relative.
  def ovl_glob(rel_pattern)
    gem_files = Dir.glob(File.join(GEM_ROOT, rel_pattern)).map do |path|
      path.sub(GEM_ROOT+"/", "")
    end

    (gem_files + Dir.glob(rel_pattern)).uniq
  end

  # Returns the absolute path of rel_file within the current directory or,
  # if it doesn't exist, from the gem root directory.
  #
  # Raises Errno::ENOENT if neither of them exist.
  def ovl_expand_file(rel_file)
    if File.exist?(rel_file)
      File.expand_path(rel_file)
    elsif File.exist?(a=File.join(GEM_ROOT, rel_file))
      File.expand_path(a)
    else
      raise Errno::ENOENT, rel_file
    end
  end

  # Returns the absolute path of rel_file within the gem root directory.
  #
  # Raises Errno::ENOENT if it doesn't exist.
  def gem_expand_file(rel_file)
    if File.exist?(a=File.join(GEM_ROOT, rel_file))
      File.expand_path(a)
    else
      raise Errno::ENOENT, rel_file
    end
  end

  def eval_file(filename)
    code = File.read(filename, encoding: "UTF-8")
    instance_eval(code, filename)
  end


  def ovl_read_file(file_rel)
    File.read(ovl_expand_file(file_rel), encoding: "UTF-8")
  end

  def ovl_compile_erb(erb_file_rel)
    ErbCompiler.new(erb_file_rel).result
  end

  def q_inno(text)
    '"' + text.gsub('"', '""') + '"'
  end
end
end
end
