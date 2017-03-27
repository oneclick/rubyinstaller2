self.compiledir = File.join(thisdir, "ruby-#{package.rubyver}")
self.pkgbuild = File.join(compiledir, "PKGBUILD.erb")
self.pkgfile = File.join(compiledir, "#{package.pacman_arch}-ruby-#{package.rubyver}-1-any.pkg.tar.xz")
