$: << File.expand_path("../lib", __FILE__)

require "ruby_installer/build"
require "bundler/gem_tasks"
require "rake/clean"
require "find"

include RubyInstaller::Build::Utils

task :gem => :build

# Forward package build tasks to the sub Rakefiles.
%w[ri ri-msys].each do |packname|
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

  # Add all package dirs/files to `rake clean` which are not registered in git and don't contain any files registered in git.
  gitfiles = `git ls-files -z`.split("\0")
  clean_list = Enumerator.new do |y|
    Find.find("packages/#{packname}") do |path|
      path = path.gsub(/\A\.\//, "") # remove prefix "./"
      unless gitfiles.find { |gf| gf.start_with?(path) }
        y << path
        Find.prune
      end
    end
  end
  CLEAN.include(clean_list.to_a)
end

libtest = "test/helper/libtest.dll"
file libtest => libtest.sub(".dll", ".c") do |t|
  RubyInstaller::Build.enable_msys_apps
  sh RbConfig::CONFIG['CC'], "-shared", t.prerequisites.first, "-o", t.name
end
CLEAN.include(libtest)

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
  desc "Update date in CHANGELOG file and set a git tag"
  task "tag", [:name] do |_task, args|
    release = RubyInstaller::Build::Release.new

    # Enable this to update release date in CHANGELOG files
    # release.update_history(args[:name])
    release.tag_version(args[:name])
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

  task "appveyor_upload" do
    files = ARGV[ARGV.index("--")+1 .. -1]
    files.each { |f| task(f) }
    if ENV['DEPLOY_TAG'].to_s.include?(ENV['target_ruby'])
      puts "Upload #{ENV['DEPLOY_TAG']}: #{files}"

      require "ruby_installer/build"
      RubyInstaller::Build.enable_msys_apps

      sh "c:/msys64/usr/bin/mkdir -p /c/Users/appveyor/.gnupg"
      sh "gpg --batch --passphrase %GPGPASSWD% --decrypt appveyor-key.asc.asc | gpg --import"
      sh "c:/msys64/usr/bin/mkdir artifacts"
      sh "cp", "-v", *files, "artifacts/"
      sh "ls artifacts/* | xargs -n1 gpg --verbose --detach-sign --armor"
      sh "rake release:upload -- artifacts/*"
    else
      puts "No release upload"
    end
  end
  CLEAN.include("artifacts")
end

namespace "docker" do
  task :image do
    rm_rf "docker/gitrepo"
    cp_r ".git", "docker/gitrepo"
    sh "docker build -t ri2 docker"
  end

  desc "Run all builds"
  multitask :builds

  %w[ri ri-msys].each do |package|
    %w[x86 x64].each do |arch|
      task "#{package}-#{arch}" => :image do
        # Use the cache of our main MSYS2 environment for package install
        cachedir = File.expand_path("../cache/#{package}-#{arch}", __FILE__)
        mkdir_p cachedir
        puts "Using pacman cache in #{cachedir}"

        pwd = Dir.pwd
        pkgdir = "#{pwd}/pkg"
        mkdir_p pkgdir

        sh "docker run --rm -v #{cachedir}:c:/ruby24-x64/msys64/var/cache/pacman -v #{pkgdir}:c:/build/pkg ri2 cmd /c rake PACKAGE=#{package} ARCH=#{arch}"
      end

      multitask :builds => "#{package}-#{arch}"
    end
  end
end

CLOBBER.include("pkg")
CLOBBER.include("cache")
