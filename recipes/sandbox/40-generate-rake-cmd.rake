file File.join(sandboxdir, "bin/rake.cmd") => File.join(unpackdirmgw, "bin/rake.bat") do |t|
  puts "generate #{t.name}"
  out = File.binread(t.prerequisites.first)
    .gsub("\\#{package.mingwdir}\\bin\\", "%~dp0")
    .gsub(/"[^"]*\/bin\/rake"/, "\"%~dp0rake\"")
  File.binwrite(t.name, out)
end
