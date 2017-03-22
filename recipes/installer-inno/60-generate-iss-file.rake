iss_files = ovl_glob("#{thisdir}/*.iss*").map{|f| ovl_expand_file(f) }

# Compile the iss file from ERB template
self.iss_compiler = RubyInstaller::Build::ErbCompiler.new(File.join(thisdir, "rubyinstaller.iss.erb"), File.join(thisdir, "#{package.name}.iss"))
file iss_compiler.result_filename => [iss_compiler.erb_filename_abs] + iss_files - [iss_compiler.result_filename] do |t|
  puts "erb #{t.name}"
  iss_compiler.write_result(self)
end
