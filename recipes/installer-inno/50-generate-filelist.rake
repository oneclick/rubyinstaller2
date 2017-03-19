self.filelist_iss = "#{thisdir}/filelist-ruby-#{package.rubyver}-#{package.ruby_arch}.iss"
directory File.dirname(filelist_iss)
file filelist_iss => [__FILE__, ovl_expand_file(sandbox_task.sandboxfile_listfile), ovl_expand_file(sandbox_task.sandboxfile_arch_listfile), File.dirname(filelist_iss)] do
  puts "generate #{filelist_iss}"
  out = sandbox_task.sandboxfiles.map do |path|
    if File.directory?(path)
      "Source: ../../#{path}/*; DestDir: {app}/#{path.gsub(sandboxdir+"/", "")}; Flags: recursesubdirs createallsubdirs"
    else
      "Source: ../../#{path}; DestDir: {app}/#{File.dirname(path.gsub(sandboxdir+"/", ""))}"
    end
  end.join("\n")
  File.write(filelist_iss, out)
end
