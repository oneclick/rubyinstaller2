desc "sandbox for ruby-#{package.rubyver}-#{package.arch}"
task "sandbox" => ["unpack", __FILE__, ovl_expand_file(sandboxfile_listfile), ovl_expand_file(sandboxfile_arch_listfile)] + sandboxfiles
