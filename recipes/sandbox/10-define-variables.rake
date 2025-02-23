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
self.fiddle_so_path = case
  when package.rubyver2 == "3.4"
    "lib/ruby/#{package.rubylibver}/#{package.ruby_arch}/fiddle.so"
  when package.rubyver2 == "3.5"
    "lib/ruby/gems/#{package.rubylibver}/extensions/#{package.ruby_arch.sub(/i.86-mingw/, "x86-mingw")}/#{package.rubylibver}/fiddle-1.1.6/fiddle.so"
end
