$: << File.expand_path("../lib", __FILE__)

task :devkit do
  require_relative "lib/devkit"
end

WINDOWS_CMD_SHEBANG = <<-EOT.freeze
:""||{ ""=> %q<-*- ruby -*-
@"%~dp0ruby" -x "%~f0" %*
@exit /b %ERRORLEVEL%
};{ #
bindir="${0%/*}" #
exec "$bindir/ruby" -x "$0" "$@" #
>, #
} #
EOT

rubies = Dir["package/ruby-*"].map do |dir|
  File.basename(dir).gsub("ruby-", "")
end

rubies.each do |rubyver|
  namespace "ruby-#{rubyver}" do
    rubyver2 = rubyver[/^\d+\.\d+/]
    packdir = File.join("package", "ruby-#{rubyver}")

    # TODO: Fix quick'n dirty building of package name
    packagefile = File.join(packdir, "mingw-w64-x86_64-ruby-#{rubyver}-1-any.pkg.tar.xz")

    desc "Build pacman package for ruby-#{rubyver}"
    task "compile" => [:devkit, packagefile]

    file packagefile => [File.join(packdir, "PKGBUILD")] do
      chdir(packdir) do
        rm_rf(["pkg", "src"])
        sh "sh", "makepkg-mingw", "-sf"
      end
    end

    sandboxdir = "sandbox/ruby-#{rubyver}"
    sandboxdirmgw = File.join(sandboxdir, "mingw64")
    sandboxdir_abs = File.expand_path("../" + sandboxdir, __FILE__)
    rootdir = "/tmp/rubyinstaller/ruby-#{rubyver}"
    ruby_exe = "#{sandboxdirmgw}/bin/ruby.exe"

    desc "Build sandbox for ruby-#{rubyver}"
    task "sandbox" => [:devkit, "compile", ruby_exe]

    file ruby_exe => packagefile do
      # pacman doesn't work on automount paths (/c/path), so mount explicit
      mkdir_p File.join(ENV['RI_DEVKIT'], rootdir)
      mkdir_p sandboxdir
      rm_rf sandboxdir
      sh "mount", sandboxdir_abs, rootdir

      %w[var/cache/pacman/pkg var/lib/pacman].each do |dir|
        mkdir_p File.join(sandboxdir, dir)
      end

      sh "pacman --root #{rootdir} -Sy"
      sh "pacman --root #{rootdir} --noconfirm -U #{packagefile}"
      sh "umount", rootdir
      touch ruby_exe
    end

    installer_exe = "installer/rubyinstaller-#{rubyver}-x64.exe"
    installerfile_listfile = "installer/#{File.basename(installer_exe, ".exe")}.files"
    installerfile_list = File.readlines(installerfile_listfile)
    installerfile_list = installerfile_list.map{|path| File.join(sandboxdirmgw, path.chomp)}
    installerfiles = installerfile_list.map do |path|
      if File.directory?(path)
        Dir[path+"/**/*"].reject{|f| File.directory?(f) }
      else
        path
      end
    end.flatten
    installerfiles.each do |path|
      file path
    end

    desc "Build installer for ruby-#{rubyver}"
    task "installer" => [:devkit, "sandbox", installer_exe]

    file File.join(sandboxdirmgw, "bin/rake.cmd") do |t|
      out = File.read(t.name.gsub(".cmd", ".bat"))
        .gsub("\\mingw64\\bin\\", "%~dp0")
        .gsub(/"[^"]*\/bin\/rake"/, "\"%~dp0rake\"")
      File.write(t.name, out)
    end

    file File.join(sandboxdirmgw, "bin/rubydevkit.cmd") do |t|
      cp "lib/rubydevkit.cmd", t.name
    end

    file File.join(sandboxdirmgw, "lib/ruby/site_ruby/devkit.rb") do |t|
      mkdir_p File.dirname(t.name)
      cp "lib/devkit.rb", t.name
    end

    file File.join(sandboxdirmgw, "lib/ruby/site_ruby/ruby_installer.rb") do |t|
      mkdir_p File.dirname(t.name)
      cp "lib/ruby_installer.rb", t.name
    end

    file File.join(sandboxdirmgw, "lib/ruby/#{rubyver2}.0/rubygems/defaults/operating_system.rb") do |t|
      mkdir_p File.dirname(t.name)
      cp "lib/operating_system.rb", t.name
    end

    filelist_iss = "installer/filelist-ruby-#{rubyver}-x64-mingw32.iss"
    file filelist_iss => [__FILE__, installerfile_listfile] do
      puts "generate #{filelist_iss}"
      out = installerfiles.map do |path|
        "Source: ../#{path}; DestDir: {app}/#{File.dirname(path.gsub(sandboxdirmgw+"/", ""))}"
      end.join("\n")
      File.write(filelist_iss, out)
    end

    default_inst_dir = "C:\\Ruby#{rubyver2.gsub(".","")}-x64"
    iss_files = Dir["installer/*.iss"]
    file installer_exe => (installerfiles + iss_files + [filelist_iss]) do
      sh "cmd", "/c", "iscc", "installer/rubyinstaller.iss", "/Q", "/dRubyVersion=#{rubyver}", "/dRubyPatch=0", "/dRubyBuildPlatform=x64-mingw32", "/dRubyShortPlatform=-x64", "/dDefaultDirName=#{default_inst_dir}", "/O#{File.dirname(installer_exe)}", "/F#{File.basename(installer_exe, ".exe")}"
    end
  end
end
