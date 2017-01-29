require "base_task"

class InstallerTask < BaseTask
  def initialize(*args)
    super
    sandboxdir = sandbox_task.sandboxdir
    self.installer_exe = "installer/rubyinstaller-#{package.rubyver_pkgrel}-#{package.arch}.exe"

    desc "installer for ruby-#{package.rubyver}-#{package.arch}"
    task "installer" => [:devkit, "sandbox", installer_exe]

    filelist_iss = "installer/filelist-ruby-#{package.rubyver}-#{package.ruby_arch}.iss"
    file filelist_iss => [__FILE__, sandbox_task.sandboxfile_listfile, sandbox_task.sandboxfile_arch_listfile] do
      puts "generate #{filelist_iss}"
      out = sandbox_task.sandboxfiles.map do |path|
        if File.directory?(path)
          "Source: ../#{path}/*; DestDir: {app}/#{path.gsub(sandboxdir+"/", "")}; Flags: recursesubdirs createallsubdirs"
        else
          "Source: ../#{path}; DestDir: {app}/#{File.dirname(path.gsub(sandboxdir+"/", ""))}"
        end
      end.join("\n")
      File.write(filelist_iss, out)
    end

    iss_files = Dir["installer/*.iss"]
    file installer_exe => (sandbox_task.sandboxfiles + iss_files + [filelist_iss]) do
      sh "cmd", "/c", "iscc", "installer/rubyinstaller.iss", "/Q", "/dRubyVersion=#{package.rubyver}", "/dRubyBuildPlatform=#{package.ruby_arch}", "/dRubyShortPlatform=-#{package.arch}", "/dDefaultDirName=#{package.default_instdir}", "/dPackageRelease=#{package.pkgrel}", "/O#{File.dirname(installer_exe)}", "/F#{File.basename(installer_exe, ".exe")}"
    end
  end
end
