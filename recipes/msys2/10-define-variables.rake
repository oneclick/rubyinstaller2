# Use another mirror as long as repo.msys2.org is down
# self.msys2_base_tar_url = "http://repo.msys2.org/distrib/msys2-#{package.msys_arch}-latest.tar.xz"
self.msys2_base_tar_url = "https://www2.futureware.at/~nickoe/msys2-mirror/distrib/msys2-#{package.msys_arch}-latest.tar.xz"
self.msys2_base_tar_file = File.join(thisdir, File.basename(self.msys2_base_tar_url))
self.sandboxdir = "#{thisdir}/#{package.mingwdir}/#{package.msysdir}"
self.devtools = File.join(sandboxdir, "devtools_installed")
self.before_init_filelist = File.join(sandboxdir, "before_init_filelist")
self.after_init_filelist = File.join(sandboxdir, "after_init_filelist")
