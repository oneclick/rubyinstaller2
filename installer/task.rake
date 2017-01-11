require "ostruct"
require "rake"

class InstallerTask < OpenStruct
  include Rake::DSL

  def initialize(*args)
    super
    sandboxdirmgw = sandbox_task.sandboxdirmgw
    self.installer_exe = "installer/rubyinstaller-#{package.rubyver_pkgrel}-x64.exe"
    installerfile_listfile = "installer/rubyinstaller-#{package.rubyver}-x64.files"
    installerfiles = File.readlines(installerfile_listfile).map{|path| File.join(sandboxdirmgw, path.chomp)}
    installerfiles.each do |path|
      file path
    end

    desc "Build installer for ruby-#{package.rubyver}"
    task "installer" => [:devkit, "sandbox", installer_exe]

    file File.join(sandboxdirmgw, "bin/rake.cmd") => File.join(sandboxdirmgw, "bin/rake.bat") do |t|
      out = File.read(t.prerequisites.first)
        .gsub("\\mingw64\\bin\\", "%~dp0")
        .gsub(/"[^"]*\/bin\/rake"/, "\"%~dp0rake\"")
      File.write(t.name, out)
    end

    copy_files = {
      "resources/files/rubydevkit.cmd" => "bin/rubydevkit.cmd",
      "resources/files/setrbvars.cmd" => "bin/setrbvars.cmd",
      "resources/files/operating_system.rb" => "lib/ruby/#{package.rubyver2}.0/rubygems/defaults/operating_system.rb",
      "resources/icons/ruby-doc.ico" => "share/doc/ruby/html/images/ruby-doc.ico",
      "lib/devkit.rb" => "lib/ruby/site_ruby/devkit.rb",
      "lib/ruby_installer.rb" => "lib/ruby/site_ruby/ruby_installer.rb",
    }
    copy_files.each do |source, dest|
      file File.join(sandboxdirmgw, dest) => source do |t|
        mkdir_p File.dirname(t.name)
        cp t.prerequisites.first, t.name
      end
    end

    filelist_iss = "installer/filelist-ruby-#{package.rubyver}-x64-mingw32.iss"
    file filelist_iss => [__FILE__, installerfile_listfile] do
      puts "generate #{filelist_iss}"
      out = installerfiles.map do |path|
        if File.directory?(path)
          "Source: ../#{path}/*; DestDir: {app}/#{path.gsub(sandboxdirmgw+"/", "")}; Flags: recursesubdirs createallsubdirs"
        else
          "Source: ../#{path}; DestDir: {app}/#{File.dirname(path.gsub(sandboxdirmgw+"/", ""))}"
        end
      end.join("\n")
      File.write(filelist_iss, out)
    end

    default_inst_dir = "C:\\Ruby#{package.rubyver2.gsub(".","")}-x64"
    iss_files = Dir["installer/*.iss"]
    file installer_exe => (installerfiles + iss_files + [filelist_iss]) do
      sh "cmd", "/c", "iscc", "installer/rubyinstaller.iss", "/Q", "/dRubyVersion=#{package.rubyver}", "/dRubyBuildPlatform=x64-mingw32", "/dRubyShortPlatform=-x64", "/dDefaultDirName=#{default_inst_dir}", "/dPackageRelease=#{package.pkgrel}", "/O#{File.dirname(installer_exe)}", "/F#{File.basename(installer_exe, ".exe")}"
    end
  end
end
