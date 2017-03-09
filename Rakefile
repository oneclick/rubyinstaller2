$: << File.expand_path("../lib", __FILE__)

require "ruby_installer/build"
require "bundler/gem_tasks"

include RubyInstaller::Build::Utils

task :gem => :build

# Forward rubyinstaller build tasks to the sub Rakefile.
namespace "rubyinstaller" do |ns|
  Rake::TaskManager.record_task_metadata = true
  Rake.load_rakefile "packages/rubyinstaller/Rakefile"
  ns.tasks.select(&:comment).each do |t|
    name, comment = t.name.sub(/.*?:/, ""), t.comment
    t.clear
    desc comment
    task name do
      chdir "packages/rubyinstaller" do
        sh "rake", name
      end
    end
  end
end

libtest = "test/helper/libtest.dll"
file libtest => libtest.sub(".dll", ".c") do |t|
  RubyInstaller::Build.enable_msys_apps
  sh RbConfig::CONFIG['CC'], "-shared", t.prerequisites.first, "-o", t.name
end

desc "Run tests on the Ruby installation"
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
