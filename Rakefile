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
    sandbox = SandboxTask.new( package: pack, compile_task: compile )
    InstallerTask.new( package: pack, sandbox_task: sandbox )
  end

  desc "Build all for #{nsp}"
  task nsp => "#{nsp}:installer"

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
end

namespace :update do
  directory "resources/ssl"

  desc "Download latest SSL trust certificates"
  task :sslcerts => "resources/ssl" do
    sh "curl -o resources/ssl/cacert.pem https://curl.haxx.se/ca/cacert.pem"
  end
end
