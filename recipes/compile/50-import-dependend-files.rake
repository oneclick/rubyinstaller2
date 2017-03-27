# Copy other source files to the current working directory
self.source_files = File.read(pkgbuild_compiler.erb_filename_abs, encoding: 'utf-8')
    .match(/source=\((.*?)\)/m)[1].split
    .reject{|f| f=~/https?:\/\// }
    .map{|f| File.join(compiledir, f) }

source_files.each do |f|
  file f => gem_expand_file(f) do |t|
    if f=~/\.ico$/
      cp t.prerequisites.first, f
    else
      puts "cp #{t.prerequisites.first} #{f}"
      # Change CRLF to LF on all text files, because the file hashs are for LFs.
      # Just in case the git checkout was with CRLF.
      File.binwrite(f, File.read(t.prerequisites.first))
    end
  end
end
