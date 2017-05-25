# Use the cache of our main MSYS2 environment for package install
cachedir = File.join(Build.msys2_installation.msys_path, "/var/cache/pacman/pkg")

file self.devtools => [self.sandboxdir] do |t|
  msys = RubyInstaller::Build::Msys2Installation.new(msys_path: self.sandboxdir, mingwarch: package.mingwdir, mingw_package_prefix: package.pacman_arch)
  msys.with_msys_apps_enabled do
    # initialize MSYS2
    sh "sh", "-lc", "true"
    # retrieve the pacman cache dir
    cachedir2 = IO.popen(["sh", "-lc", "cygpath -u #{cachedir.inspect}"], &:read).chomp
    cachedir_arg = "--cachedir=#{cachedir2}"
    # Update the package database and core system packages
    sh "sh", "-lc", "pacman #{cachedir_arg.inspect} -Syu --noconfirm"
    # Update the rest
    sh "sh", "-lc", "pacman #{cachedir_arg.inspect} -Su --noconfirm"
    # Install the development tools
    RubyInstaller::Build::ComponentsInstaller.new(msys: msys, pacman_args: ["--needed", "--noconfirm", cachedir_arg]).install(%w[dev_tools])
  end
  touch self.devtools
end
