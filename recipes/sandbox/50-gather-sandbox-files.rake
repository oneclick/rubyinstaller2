self.sandboxfile_listfile = "#{thisdir}/rubyinstaller-#{package.rubyver}.files"
self.sandboxfile_arch_listfile = "#{thisdir}/rubyinstaller-#{package.rubyver}-#{package.arch}.files"
sandboxfiles_rel = File.readlines(ovl_expand_file(sandboxfile_listfile)) + File.readlines(ovl_expand_file(sandboxfile_arch_listfile))
sandboxfiles_rel = sandboxfiles_rel.map{|path| path.chomp }
sandboxfiles_rel += import_files.values
self.sandboxfiles += sandboxfiles_rel.map{|path| File.join(sandboxdir, path)}
# go through directories and gather all files recursively
self.sandboxfiles = sandboxfiles.flat_map do |path|
  unpack_path = path.sub(sandboxdir, unpackdirmgw)
  if File.directory?(unpack_path)
    Dir.glob(File.join(unpack_path, "**/*")).map do |pa|
      pa.sub(unpackdirmgw, sandboxdir)
    end
  else
    path
  end
end
