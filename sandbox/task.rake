require "base_task"

class SandboxTask < BaseTask
  def initialize(*args)
    super
    self.sandboxdir = "sandbox/ruby-#{package.rubyver}"
    self.sandboxdirmgw = File.join(sandboxdir, package.mingwdir)
    self.sandboxdir_abs = File.expand_path(sandboxdir, package.rootdir)
    ruby_exe = "#{sandboxdirmgw}/bin/ruby.exe"

    desc "Build sandbox for ruby-#{package.rubyver}"
    task "sandbox" => [:devkit, "compile", ruby_exe]

    file ruby_exe => compile_task.pkgfile do
      # pacman doesn't work on automount paths (/c/path), so that we
      # mount to /tmp
      pmrootdir = "/tmp/rubyinstaller/ruby-#{package.rubyver}"
      mkdir_p File.join(ENV['RI_DEVKIT'], pmrootdir)
      mkdir_p sandboxdir
      rm_rf sandboxdir
      %w[var/cache/pacman/pkg var/lib/pacman].each do |dir|
        mkdir_p File.join(sandboxdir, dir)
      end

      msys_sh <<-EOT
        mount #{sandboxdir_abs.inspect} #{pmrootdir.inspect} &&
        pacman --root #{pmrootdir.inspect} -Sy &&
        pacman --root #{pmrootdir.inspect} --noconfirm -U #{compile_task.pkgfile.inspect};
        umount #{pmrootdir.inspect}
      EOT
      touch ruby_exe
    end
  end
end
