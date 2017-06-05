# Use the cache of our main MSYS2 environment for package install
cachedir = File.join(Build.msys2_installation.msys_path, "/var/cache/pacman/pkg")

file self.devtools => [self.after_init_filelist] do |t|
  msys = RubyInstaller::Build::Msys2Installation.new(msys_path: self.sandboxdir, mingwarch: package.mingwdir, mingw_package_prefix: package.pacman_arch)
  msys.with_msys_apps_enabled do
    # retrieve the pacman cache dir
    cachedir2 = IO.popen(["cygpath", "-u", cachedir], &:read).chomp
    # Install the development tools
    RubyInstaller::Build::ComponentsInstaller.new(msys: msys, pacman_args: ["--needed", "--noconfirm", "--cachedir=#{cachedir2}"]).install(%w[pacman_update dev_tools])
  end
  touch self.devtools
end
