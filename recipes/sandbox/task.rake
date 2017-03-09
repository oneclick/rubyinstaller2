class SandboxTask < RubyInstaller::Build::BaseTask
  def initialize(*args)
    super
    unpackdirmgw = unpack_task.unpackdirmgw
    thisdir = "recipes/sandbox"
    self.sandboxdir = "#{thisdir}/ruby-#{package.rubyver_pkgrel}-#{package.arch}"

    copy_files = {
      "resources/files/ridk.cmd" => "bin/ridk.cmd",
      "resources/files/ridk.ps1" => "bin/ridk.ps1",
      "resources/files/setrbvars.cmd" => "bin/setrbvars.cmd",
      "resources/files/operating_system.rb" => "lib/ruby/#{package.rubyver2}.0/rubygems/defaults/operating_system.rb",
      "resources/icons/ruby-doc.ico" => "share/doc/ruby/html/images/ruby-doc.ico",
      "resources/ssl/cacert.pem" => "ssl/cert.pem",
      "resources/ssl/README-SSL.md" => "ssl/README-SSL.md",
      "resources/ssl/c_rehash.rb" => "ssl/certs/c_rehash.rb",
      "#{thisdir}/LICENSE.txt" => "LICENSE.txt",
    }

    # Add "ruby_installer/runtime" libs to the package.
    # Copy certain files from "ruby_installer/build" to "ruby_installer/runtime".
    lib_runtime_files.each do |file|
      dfile = file.sub(%r{^lib/}, "")
      dfile.sub!(%r{/build/}, "/runtime/")
      copy_files[file] = "lib/ruby/site_ruby/2.4.0/#{dfile}"
    end

    self.sandboxfile_listfile = "#{thisdir}/rubyinstaller-#{package.rubyver}.files"
    self.sandboxfile_arch_listfile = "#{thisdir}/rubyinstaller-#{package.rubyver}-#{package.arch}.files"
    self.sandboxfiles_rel = File.readlines(ovl_expand_file(sandboxfile_listfile)) + File.readlines(ovl_expand_file(sandboxfile_arch_listfile))
    self.sandboxfiles_rel = self.sandboxfiles_rel.map{|path| path.chomp }
    self.sandboxfiles_rel += copy_files.values
    self.sandboxfiles = self.sandboxfiles_rel.map{|path| File.join(sandboxdir, path)}

    file File.join(sandboxdir, "bin/rake.cmd") => File.join(unpackdirmgw, "bin/rake.bat") do |t|
      puts "generate #{t.name}"
      out = File.binread(t.prerequisites.first)
        .gsub("\\#{package.mingwdir}\\bin\\", "%~dp0")
        .gsub(/"[^"]*\/bin\/rake"/, "\"%~dp0rake\"")
      File.binwrite(t.name, out)
    end

    versionfile = File.join(sandboxdir, "lib/ruby/site_ruby/2.4.0/ruby_installer/runtime/package_version.rb")
    directory File.dirname(versionfile)
    file versionfile => [File.dirname(versionfile), ovl_expand_file(package.pkgbuild),
                         File.exist?('.git/logs/HEAD') && '.git/logs/HEAD'].select{|a|a} do |t|
      puts "generate #{t.name}"
      File.binwrite t.name, <<-EOT
module RubyInstaller
module Runtime
  PACKAGE_VERSION = #{package.rubyver_pkgrel.inspect}
  GIT_COMMIT = #{`git rev-parse HEAD`.chomp[0, 7].inspect}
end
end
      EOT
    end

    copy_files.each do |source, dest|
      file File.join(sandboxdir, dest) => ovl_expand_file(source) do |t|
        mkdir_p File.dirname(t.name)
        content = File.binread(t.prerequisites.first)
        # Rewrite certain files from RubyInstaller::Build to RubyInstaller::Runtime.
        rewrite_done = false
        content.gsub!(REWRITE_MARK) do
          rewrite_done = true
          "module Runtime # Rewrite from #{t.prerequisites.first}"
        end
        File.binwrite(t.name, content)
        puts "copy#{" with rewrite" if rewrite_done} #{t.prerequisites.first} #{t.name}"
      end
    end

    gem_cmd = File.join(sandboxdir, "bin/gem.cmd")
    package.install_gems.each do |gem|
      gemspec = File.join(sandboxdir, "lib/ruby/gems/2.4.0/specifications/#{gem}.gemspec")
      file gemspec do
        with_env(GEM_HOME: nil, GEM_PATH: nil, RUBYOPT: nil, RUBYLIB: nil) do
          /(?<gem_name>.*)-(?<gem_ver>.*)/ =~ gem || raise(ArgumentError, "invalid gem name #{gem.inspect}")
          RubyInstaller::Build::Gems.install(gem_name, gem_version: gem_ver, gem_cmd: gem_cmd)
        end
      end
      self.sandboxfiles << gemspec
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
    task "sandbox" => ["unpack", __FILE__, ovl_expand_file(sandboxfile_listfile), ovl_expand_file(sandboxfile_arch_listfile)] + sandboxfiles
  end
end
