$: << File.expand_path("../lib", __FILE__)

require "build_utils"
require "ruby_package"
require "ruby_installer"
Dir['*/task.rake'].each{|f| load(f) }

include BuildUtils

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
    InstallerInnoTask.new( package: pack, sandbox_task: sandbox )
    Archive7zTask.new( package: pack, sandbox_task: sandbox )
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

namespace :ssl do
  directory "resources/ssl"

  desc "Download latest SSL trust certificates"
  task :update => "resources/ssl" do
    pem_content = download_ssl_cacert_pem
    File.binwrite("resources/ssl/cacert.pem", pem_content)
  end

  task :update_check do
    old_content = remove_comments(File.binread("resources/ssl/cacert.pem"))
    print "Download SSL CA list..."
    new_content = remove_comments(download_ssl_cacert_pem)
    if old_content == new_content
      puts " => unchanged"
    else
      puts " => changed"
      raise "cacert.pem has changed"
    end
  end
end
