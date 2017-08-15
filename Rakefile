$: << File.expand_path("../lib", __FILE__)

require "ruby_installer/build"
require "bundler/gem_tasks"

include RubyInstaller::Build::Utils

task :gem => :build

# Forward package build tasks to the sub Rakefiles.
%w[rubyinstaller rubybundle].each do |packname|
  namespace packname do |ns|
    Rake::TaskManager.record_task_metadata = true
    Rake.load_rakefile "packages/#{packname}/Rakefile"
    ns.tasks.select(&:comment).each do |t|
      name, comment = t.name.sub(/.*?:/, ""), t.comment
      t.clear
      desc comment
      task name do
        chdir "packages/#{packname}" do
          sh "rake", name
        end
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
    ca_file = RubyInstaller::Build::CaCertFile.new
    File.binwrite("resources/ssl/cacert.pem", ca_file.content)
  end

  task :update_check do
    old_file = RubyInstaller::Build::CaCertFile.new(File.binread("resources/ssl/cacert.pem"))
    print "Download SSL CA list..."
    begin
      new_file = RubyInstaller::Build::CaCertFile.new
    rescue SocketError => err
      puts " failed: #{err} (#{err.class})"
    else
      if old_file == new_file
        puts " => unchanged"
      else
        puts " => changed"
        raise "cacert.pem has changed"
      end
    end
  end
end

namespace "release" do
  task "tag" do
    release = RubyInstaller::Build::Release.new

    release.update_history
    release.tag_version
  end

  task "upload" do
    files = ARGV[ARGV.index("--")+1 .. -1]

    release = RubyInstaller::Build::Release.new
    release.upload_to_github(
      tag: ENV['DEPLOY_TAG'],
      repo: ENV['DEPLOY_REPO_NAME'],
      token: ENV['DEPLOY_TOKEN'],
      files: files
    )
  end
end
