self.unpackdirmgw = unpack_task.unpackdirmgw
self.thisdir = "recipes/sandbox"
self.sandboxdir = "#{thisdir}/ruby-#{package.rubyver_pkgrel}-#{package.arch}"
self.import_files = {}
self.sandboxfiles = []
