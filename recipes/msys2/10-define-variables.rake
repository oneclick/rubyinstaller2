self.msys2_base_tar_url = "http://repo.msys2.org/distrib/msys2-#{package.msys_arch}-latest.tar.xz"
self.msys2_base_tar_file = File.join(thisdir, File.basename(self.msys2_base_tar_url))
self.sandboxdir = "#{thisdir}/#{package.msysdir}"
self.devtools = File.join(sandboxdir, "devtools_installed")
self.before_init_filelist = File.join(sandboxdir, "before_init_filelist")
self.after_init_filelist = File.join(sandboxdir, "after_init_filelist")
