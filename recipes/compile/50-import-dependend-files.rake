# Copy other source files to the current working directory
self.source_files = File.read(pkgbuild_compiler.erb_filename_abs, encoding: 'utf-8')
    .match(/source=\((.*?)\)/m)[1].split
    .reject{|f| f=~/https?:\/\// }
    .map{|f| File.join(package.compiledir, f) }

source_files.each do |f|
  file f => gem_expand_file(f) do |t|
    cp t.prerequisites.first, f
  end
end
