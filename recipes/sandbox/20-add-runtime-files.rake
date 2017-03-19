# Add "ruby_installer/runtime" libs to the package.
# Copy certain files from "ruby_installer/build" to "ruby_installer/runtime".
lib_runtime_files.each do |file|
  dfile = file.sub(%r{^lib/}, "")
  dfile.sub!(%r{/build/}, "/runtime/")
  import_files[file] = "lib/ruby/site_ruby/2.4.0/#{dfile}"
end
