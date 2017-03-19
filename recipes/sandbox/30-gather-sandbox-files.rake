self.sandboxfile_listfile = "#{thisdir}/rubyinstaller-#{package.rubyver}.files"
self.sandboxfile_arch_listfile = "#{thisdir}/rubyinstaller-#{package.rubyver}-#{package.arch}.files"
self.sandboxfiles_rel = File.readlines(ovl_expand_file(sandboxfile_listfile)) + File.readlines(ovl_expand_file(sandboxfile_arch_listfile))
self.sandboxfiles_rel = self.sandboxfiles_rel.map{|path| path.chomp }
self.sandboxfiles_rel += import_files.values
self.sandboxfiles = self.sandboxfiles_rel.map{|path| File.join(sandboxdir, path)}
