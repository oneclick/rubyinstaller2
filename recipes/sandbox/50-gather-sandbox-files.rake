self.sandboxfile_listfile = "#{thisdir}/rubyinstaller-#{package.rubyver}.files"
self.sandboxfile_arch_listfile = "#{thisdir}/rubyinstaller-#{package.rubyver}-#{package.arch}.files"
sandboxfiles_rel = File.readlines(ovl_expand_file(sandboxfile_listfile)) + File.readlines(ovl_expand_file(sandboxfile_arch_listfile))
sandboxfiles_rel = sandboxfiles_rel.map{|path| path.chomp }
sandboxfiles_rel += import_files.values
self.sandboxfiles += sandboxfiles_rel.map{|path| File.join(sandboxdir, path)}
