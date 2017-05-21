# Use one file out of many to indicate installation of devtools
self.devtools = File.join(self.sandboxdir, "/var/lib/pacman/local/mingw-w64-x86_64-gcc-6.3.0-3/desc")

file self.devtools => [self.sandboxdir] do |t|
  msys = RubyInstaller::Build::Msys2Installation.new(self.sandboxdir)
  msys.with_msys_apps_enabled do
    sh "sh -lc 'pacman -Syu --noconfirm' # Update the package database and core system packages"
    sh "sh -lc 'pacman -Su --noconfirm' # Update the rest"
    RubyInstaller::Build::ComponentsInstaller.new.install(%w[dev_tools])
  end
  touch self.devtools
end
