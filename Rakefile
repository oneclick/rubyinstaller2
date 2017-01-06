$: << File.expand_path("../lib", __FILE__)

task :devkit do
  require_relative "lib/devkit"
end

rubies = Dir["package/ruby-*"].map do |dir|
  File.basename(dir)
end

rubies.each do |rubyver|
  namespace rubyver do
    packdir = File.join("package", rubyver)

    # TODO: Fix quick'n dirty building of package name
    packagefile = File.join(packdir, "mingw-w64-x86_64-#{rubyver}-1-any.pkg.tar.xz")

    desc "Build pacman package for #{rubyver}"
    task "compile" => [:devkit, packagefile]

    file packagefile => [File.join(packdir, "PKGBUILD")] do
      chdir(packdir) do
        rm_rf(["pkg", "src"])
        sh "sh", "makepkg-mingw", "-sf"
      end
    end

    sandboxdir = "sandbox/#{rubyver}"
    sandboxdir_abs = File.expand_path("../" + sandboxdir, __FILE__)
    rootdir = "/tmp/rubyinstaller/#{rubyver}"
    ruby_exe = "#{sandboxdir}/mingw64/bin/ruby.exe"

    desc "Build sandbox for #{rubyver}"
    task "sandbox" => [:devkit, "#{rubyver}:compile", ruby_exe]

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

    installer_exe = "installer/" + rubyver.gsub("ruby", "rubyinstaller") + "-x64.exe"
    installerfile_listfile = "installer/#{File.basename(installer_exe, ".exe")}.files"
    installerfile_list = File.readlines(installerfile_listfile)
    installerfile_list = installerfile_list.map{|path| File.join("sandbox/#{rubyver}", path.chomp)}
    installerkeeps, installerfiles1 = installerfile_list.partition{|path| path =~ /\/KEEP$/ }
    installerfiles = installerfiles1.map do |path|
      if File.directory?(path)
        Dir[path+"/**/*"].reject{|f| File.directory?(f) }
      else
        path
      end
    end.flatten
    installerfiles.each do |path|
      file path
    end

    desc "Build installer for #{rubyver}"
    task "installer" => [:devkit, "#{rubyver}:sandbox", installer_exe]

    installerkeeps.each do |path|
      dirname = File.dirname(path)
      directory dirname
      file path => dirname do
        touch path
      end
    end

    file File.join(sandboxdir, "mingw64/bin/rake.cmd") do |t|
      out = File.read(t.name.gsub(".cmd", ".bat")).gsub("\\mingw64\\bin\\", "%~dp0")
      File.write(t.name, out)
    end

    file File.join(sandboxdir, "mingw64/lib/ruby/site_ruby/devkit.rb") do |t|
      mkdir_p File.dirname(t.name)
      cp "lib/devkit.rb", t.name
    end

    file File.join(sandboxdir, "mingw64/lib/ruby/2.4.0/rubygems/defaults/operating_system.rb") do |t|
      mkdir_p File.dirname(t.name)
      cp "lib/operating_system.rb", t.name
    end

    filelist_iss = "installer/filelist-#{rubyver}-x64-mingw32.iss"
    file filelist_iss => [__FILE__, installerfile_listfile] do
      puts "generate #{filelist_iss}"
      out = installerfiles.map do |path|
        "Source: ../#{path}; DestDir: {app}/#{File.dirname(path.gsub(sandboxdir+"/", ""))}"
      end.join("\n")
      File.write(filelist_iss, out)
    end

    iss_files = Dir["installer/*.iss"]
    file installer_exe => (installerfiles + installerkeeps + iss_files + [filelist_iss]) do
      sh "cmd", "/c", "iscc", "installer/rubyinstaller.iss", "/Qp", "/dRubyVersion=2.4.0", "/dRubyPatch=0", "/dRubyBuildPlatform=x64-mingw32", "/dRubyShortPlatform=-x64", "/O#{File.dirname(installer_exe)}", "/F#{File.basename(installer_exe, ".exe")}"
    end
  end
end
