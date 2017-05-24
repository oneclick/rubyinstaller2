self.devtools = File.join(thisdir, "devtools_installed")
# Use the cache of our main MSYS2 environment for package install
cachedir = File.join(Build.msys2_installation.msys_path, "/var/cache/pacman/pkg")

file self.devtools => [self.sandboxdir] do |t|
  msys = RubyInstaller::Build::Msys2Installation.new(self.sandboxdir)
  msys.with_msys_apps_enabled do
    # Update the package database and core system packages
    sh "sh", "-lc", "pacman --cachedir=`cygpath -u #{cachedir.inspect}` -Syu --noconfirm"
    # Update the rest
    sh "sh", "-lc", "pacman --cachedir=`cygpath -u #{cachedir.inspect}` -Su --noconfirm"
    # Install the development tools
    RubyInstaller::Build::ComponentsInstaller.new.install(%w[dev_tools])
  end
  touch self.devtools
end
