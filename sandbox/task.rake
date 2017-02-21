class SandboxTask < RubyInstaller::Build::BaseTask
  def initialize(*args)
    super
    unpackdirmgw = unpack_task.unpackdirmgw
    self.sandboxdir = "sandbox/ruby-#{package.rubyver_pkgrel}-#{package.arch}"

    copy_files = {
      "resources/files/ridk.cmd" => "bin/ridk.cmd",
      "resources/files/ridk.ps1" => "bin/ridk.ps1",
      "resources/files/setrbvars.cmd" => "bin/setrbvars.cmd",
      "resources/files/operating_system.rb" => "lib/ruby/#{package.rubyver2}.0/rubygems/defaults/operating_system.rb",
      "resources/files/rbreadline/version.rb" => "lib/ruby/site_ruby/rbreadline/version.rb",
      "resources/files/rbreadline.rb" => "lib/ruby/site_ruby/rbreadline.rb",
      "resources/files/rb-readline.rb" => "lib/ruby/site_ruby/rb-readline.rb",
      "resources/files/readline.rb"  => "lib/ruby/site_ruby/readline.rb",
      "resources/icons/ruby-doc.ico" => "share/doc/ruby/html/images/ruby-doc.ico",
      "lib/devkit.rb" => "lib/ruby/site_ruby/devkit.rb",
      "lib/ruby_installer.rb" => "lib/ruby/site_ruby/ruby_installer.rb",
      "lib/ruby_installer/colors.rb" => "lib/ruby/site_ruby/ruby_installer/colors.rb",
      "lib/ruby_installer/components/01_msys2.rb" => "lib/ruby/site_ruby/ruby_installer/components/01_msys2.rb",
      "lib/ruby_installer/components/02_pacman_update.rb" => "lib/ruby/site_ruby/ruby_installer/components/02_pacman_update.rb",
      "lib/ruby_installer/components/03_dev_tools.rb" => "lib/ruby/site_ruby/ruby_installer/components/03_dev_tools.rb",
      "lib/ruby_installer/components/base.rb" => "lib/ruby/site_ruby/ruby_installer/components/base.rb",
      "lib/ruby_installer/components_installer.rb" => "lib/ruby/site_ruby/ruby_installer/components_installer.rb",
      "lib/ruby_installer/dll_directory.rb" => "lib/ruby/site_ruby/ruby_installer/dll_directory.rb",
      "lib/ruby_installer/msys2_installation.rb" => "lib/ruby/site_ruby/ruby_installer/msys2_installation.rb",
      "lib/ruby_installer/ridk.rb" => "lib/ruby/site_ruby/ruby_installer/ridk.rb",
      "resources/ssl/cacert.pem" => "ssl/cert.pem",
      "resources/ssl/README-SSL.md" => "ssl/README-SSL.md",
      "resources/ssl/c_rehash.rb" => "ssl/certs/c_rehash.rb",
      "sandbox/LICENSE.txt" => "LICENSE.txt",
    }

    self.sandboxfile_listfile = "sandbox/rubyinstaller-#{package.rubyver}.files"
    self.sandboxfile_arch_listfile = "sandbox/rubyinstaller-#{package.rubyver}-#{package.arch}.files"
    self.sandboxfiles_rel = File.readlines(sandboxfile_listfile) + File.readlines(sandboxfile_arch_listfile)
    self.sandboxfiles_rel = self.sandboxfiles_rel.map{|path| path.chomp }
    self.sandboxfiles_rel += copy_files.values
    self.sandboxfiles = self.sandboxfiles_rel.map{|path| File.join(sandboxdir, path)}

    file File.join(sandboxdir, "bin/rake.cmd") => File.join(unpackdirmgw, "bin/rake.bat") do |t|
      puts "generate #{t.name}"
      out = File.read(t.prerequisites.first)
        .gsub("\\#{package.mingwdir}\\bin\\", "%~dp0")
        .gsub(/"[^"]*\/bin\/rake"/, "\"%~dp0rake\"")
      File.write(t.name, out)
    end

    versionfile = File.join(sandboxdir, "lib/ruby/site_ruby/ruby_installer/package_version.rb")
    directory File.dirname(versionfile)
    file versionfile => [File.dirname(versionfile), package.pkgbuild, '.git/logs/HEAD'] do |t|
      puts "generate #{t.name}"
      File.write t.name, <<-EOT
module RubyInstaller
  PACKAGE_VERSION = #{package.rubyver_pkgrel.inspect}
  GIT_COMMIT = #{`git rev-parse HEAD`.chomp[0, 7].inspect}
end
      EOT
    end

    copy_files.each do |source, dest|
      file File.join(sandboxdir, dest) => source do |t|
        mkdir_p File.dirname(t.name)
        cp t.prerequisites.first, t.name
      end
    end

    self.sandboxfiles_rel.each do |path|
      destpath = File.join(sandboxdir, path)
      directory File.dirname(destpath)
      unless Rake::Task.task_defined?(destpath)
        file destpath => [File.join(unpackdirmgw, path), File.dirname(destpath)] do |t|
          cp_r(t.prerequisites.first, t.name)
        end
      end
    end

    desc "sandbox for ruby-#{package.rubyver}-#{package.arch}"
    task "sandbox" => [:devkit, "unpack", __FILE__, sandboxfile_listfile, sandboxfile_arch_listfile] + sandboxfiles
  end
end
