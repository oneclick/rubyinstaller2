self.filelist_iss = "#{thisdir}/filelist-ruby-#{package.rubyver}-#{package.ruby_arch}.iss"
directory File.dirname(filelist_iss)
file filelist_iss => [__FILE__, ovl_expand_file(sandbox_task.sandboxfile_listfile), ovl_expand_file(sandbox_task.sandboxfile_arch_listfile), File.dirname(filelist_iss)] do
  puts "generate #{filelist_iss}"
  out = sandbox_task.sandboxfiles.map do |path|
    reltosandbox_path = path.gsub(sandboxdir+"/", "")

    if package.respond_to?(:msysdir) && reltosandbox_path.start_with?(package.msysdir)
      components = "msys2"
      flags = "uninsneveruninstall"
    elsif File.fnmatch("share/{ri,doc}/*", reltosandbox_path, File::FNM_EXTGLOB)
      components = "rdoc"
    else
      components = "ruby"
    end
    unless File.directory?(path)
      source = "../../#{path}"
      dest = "{app}/#{File.dirname(reltosandbox_path)}"
      "Source: #{source}; DestDir: #{dest}; Flags: #{flags}; Components: #{components}"
    end

  end.join("\n")
  File.write(filelist_iss, out)
end
