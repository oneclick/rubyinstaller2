task "sandbox_prepared" => ["unpack", __FILE__, ovl_expand_file(sandboxfile_listfile), ovl_expand_file(sandboxfile_arch_listfile)] + sandboxfiles

# to be defined in derived packages
task "custom_install" => "sandbox_prepared"

desc "sandbox for ruby-#{package.rubyver}-#{package.arch}"
task "sandbox" => "custom_install"
