class UnpackTask < RubyInstaller::Build::BaseTask
  def initialize(*args)
    super
    self.unpackdir = "recipes/unpack/ruby-#{package.rubyver}-#{package.arch}"
    self.unpackdirmgw = File.join(unpackdir, package.mingwdir)
    self.unpackdir_abs = File.expand_path(unpackdir, package.rootdir)
    ruby_exe = "#{unpackdirmgw}/bin/ruby.exe"

    desc "unpack ruby-#{package.rubyver} and dependend packages"
    task "unpack" => ["compile", ruby_exe]

    file ruby_exe => compile_task.pkgfile do
      # pacman doesn't work on automount paths (/c/path), so that we
      # mount to /tmp
      pmrootdir = "/tmp/rubyinstaller/ruby-#{package.rubyver}-#{package.arch}"
      mkdir_p File.join(ENV['RI_DEVKIT'], pmrootdir)
      mkdir_p unpackdir
      rm_rf unpackdir
      %w[var/cache/pacman/pkg var/lib/pacman].each do |dir|
        mkdir_p File.join(unpackdir, dir)
      end

      msys_sh <<-EOT
        mount #{unpackdir_abs.inspect} #{pmrootdir.inspect} &&
        pacman --root #{pmrootdir.inspect} -Sy &&
        pacman --root #{pmrootdir.inspect} --noconfirm -U #{compile_task.pkgfile.inspect};
        umount #{pmrootdir.inspect}
      EOT
      touch ruby_exe
    end
  end
end
