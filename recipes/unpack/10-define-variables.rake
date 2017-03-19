self.unpackdir = "recipes/unpack/ruby-#{package.rubyver}-#{package.arch}"
self.unpackdirmgw = File.join(unpackdir, package.mingwdir)
self.unpackdir_abs = File.expand_path(unpackdir, package.rootdir)
self.ruby_exe = "#{unpackdirmgw}/bin/ruby.exe"
