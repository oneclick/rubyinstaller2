$: << File.expand_path("../lib", __FILE__)

require "build_utils"
require "ruby_package"
require "ruby_installer"
Dir['*/task.rake'].each{|f| load(f) }

task :devkit do
  RubyInstaller.enable_msys_apps
end

ENV['RI_ARCHS'] ||= 'x64:x86'

ruby_packages = Dir["compile/ruby-*"].map do |compiledir|
  ENV['RI_ARCHS'].split(":").map do |arch|
    RubyPackage.new( compiledir: compiledir, arch: arch, rootdir: __dir__ ).freeze
  end
end.flatten

ruby_packages.each do |pack|

  nsp = "ruby-#{pack.rubyver}-#{pack.arch}"
  namespace nsp do
    compile = CompileTask.new( package: pack )
    unpack = UnpackTask.new( package: pack, compile_task: compile )
    sandbox = SandboxTask.new( package: pack, unpack_task: unpack )
    InstallerTask.new( package: pack, sandbox_task: sandbox )
    ArchiveTask.new( package: pack, sandbox_task: sandbox )
  end

  desc "Build all for #{nsp}"
  task nsp => ["#{nsp}:installer", "#{nsp}:archive"]

  desc "Build installers for all rubies"
  task :default => nsp
end

libtest = "test/helper/libtest.dll"
file libtest => libtest.sub(".dll", ".c") do |t|
  require "devkit"
  sh RbConfig::CONFIG['CC'], "-shared", t.prerequisites.first, "-o", t.name
end

task :test => libtest do
  sh "ruby -w -W2 -I. -e \"#{Dir["test/**/test_*.rb"].map{|f| "require '#{f}';"}.join}\" -- -v"

  # Re-test with simulated legacy Windows version.
  # This is done in a dedicated run, because it's not possible to revert a call to SetDefaultDllDirectories().
  # See https://msdn.microsoft.com/de-de/library/windows/desktop/hh310515(v=vs.85).aspx
  ENV['RI_FORCE_PATH_FOR_DLL'] = '1'
  sh "ruby -w -W2 -I. -e \"#{Dir["test/ruby_installer/test_module.rb"].map{|f| "require '#{f}';"}.join}\" -- -v"
  ENV['RI_FORCE_PATH_FOR_DLL'] = '0'
end

MOZILLA_CA_CSV_URI = "https://mozillacaprogram.secure.force.com/CA/IncludedCACertificateReportPEMCSV"

namespace :update do
  directory "resources/ssl"

  desc "Download latest SSL trust certificates"
  task :sslcerts => "resources/ssl" do
    require 'open-uri'
    require 'csv'
    require 'openssl'

    csv_data = OpenURI.open_uri(MOZILLA_CA_CSV_URI)

    File.open("resources/ssl/cacert.pem", "wb") do |fd|
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
## This file is used as default CA certificate file for Ruby
## based on RubyInstaller2.
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
    end
  end
end
