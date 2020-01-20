file ruby_exe => [self.repo_added] do
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
    pacman --root #{pmrootdir.inspect} --noconfirm -S #{install_packages.map(&:inspect).join(" ")}
    umount #{pmrootdir.inspect}
  EOT

  begin
    # For some reason pacman-5.2.1 generates package files, that prohibit changing files after installation.
    # Resetting the permissions the hard way fixes this, so that we can touch ruby.exe .
    sh "takeown /R /F \"#{unpackdir.gsub("/","\\")}\" >NUL"
    sh "icacls \"#{unpackdir.gsub("/","\\")}\" /inheritance:r /grant BUILTIN\\Users:F /T /Q"
  rescue => err
    $stderr.puts "ignoring error while adjusting permissions: #{err} (#{err.class})"
  end
  touch ruby_exe
end
