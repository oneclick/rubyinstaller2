# Add "ruby_installer/runtime" libs to the package.
# Copy certain files from "ruby_installer/build" to "ruby_installer/runtime".

REWRITE_MARK = /module Build.*Use for: Build, Runtime/

lib_runtime_files = rubyinstaller_build_gem_files.select do |file|
  file.match(%r{^lib/}) &&
  (!file.match(%r{^lib/ruby_installer/build}) || File.binread(ovl_expand_file(file))[REWRITE_MARK])
end

lib_runtime_files.each do |file|
  dfile = file.sub(%r{^lib/}, "")
  dfile.sub!(%r{/build/}, "/runtime/")
  import_files[file] = "lib/ruby/site_ruby/#{package.rubylibver}/#{dfile}"
end
