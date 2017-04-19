file File.join(sandboxdir, "bin/rake") => File.join(unpackdirmgw, "bin/rake") do |t|
  puts "Fix #{t.name} shebang"
  out = File.binread(t.prerequisites.first)
    .sub(%r{#!/.*/ruby.exe}, "#!/usr/bin/env ruby")
  File.binwrite(t.name, out)
end
