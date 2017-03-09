class InstallerInnoTask < RubyInstaller::Build::BaseTask
  def initialize(*args)
    super
    sandboxdir = sandbox_task.sandboxdir
    thisdir = "recipes/installer-inno"
    self.installer_exe = "#{thisdir}/rubyinstaller-#{package.rubyver_pkgrel}-#{package.arch}.exe"

    desc "installer for ruby-#{package.rubyver}-#{package.arch}"
    task "installer-inno" => ["sandbox", installer_exe]

    filelist_iss = "#{thisdir}/filelist-ruby-#{package.rubyver}-#{package.ruby_arch}.iss"
    directory File.dirname(filelist_iss)
    file filelist_iss => [__FILE__, ovl_expand_file(sandbox_task.sandboxfile_listfile), ovl_expand_file(sandbox_task.sandboxfile_arch_listfile), File.dirname(filelist_iss)] do
      puts "generate #{filelist_iss}"
      out = sandbox_task.sandboxfiles.map do |path|
        if File.directory?(path)
          "Source: ../../#{path}/*; DestDir: {app}/#{path.gsub(sandboxdir+"/", "")}; Flags: recursesubdirs createallsubdirs"
        else
          "Source: ../../#{path}; DestDir: {app}/#{File.dirname(path.gsub(sandboxdir+"/", ""))}"
        end
      end.join("\n")
      File.write(filelist_iss, out)
    end

    iss_files = ovl_glob("#{thisdir}/*.iss*").map{|f| ovl_expand_file(f) }
    file installer_exe => (sandbox_task.sandboxfiles + iss_files + [filelist_iss]) do
      # Compile the iss file from ERB template
      iss_erb_file = File.join(thisdir, "rubyinstaller.iss.erb")
      ri_iss_file = RubyInstaller::Build::ErbCompiler.new(iss_erb_file).write_result

      sh "cmd", "/c", "iscc", ri_iss_file, "/Q", "/dRubyVersion=#{package.rubyver}", "/dRubyBuildPlatform=#{package.ruby_arch}", "/dRubyShortPlatform=-#{package.arch}", "/dDefaultDirName=#{package.default_instdir}", "/dPackageRelease=#{package.pkgrel}", "/O#{File.dirname(installer_exe)}", "/F#{File.basename(installer_exe, ".exe")}"
    end
  end
end
