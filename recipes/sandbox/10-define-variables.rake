self.unpackdirmgw = unpack_task.unpackdirmgw
self.thisdir = "recipes/sandbox"
self.sandboxdir = "#{thisdir}/#{package.packagenameverarch}"
self.import_files = {}
self.sandboxfiles = []
self.ssl_dir = case
  when package.rubyver2 < "3.2"
    "ssl"
  when package.rubyver2 < "3.4"
    "bin/etc/ssl"
  else
    "lib/ruby/#{package.rubylibver}/etc/ssl"
end
