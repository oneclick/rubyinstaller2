self.import_files.merge!({
  "resources/files/irbrc_predefiner.rb" => "lib/ruby/site_ruby/#{package.rubyver2}.0/irbrc_predefiner.rb",
})

file File.join(sandboxdir, "bin/irb.cmd") => File.join(unpackdirmgw, "bin/irb.cmd") do |t|
  puts "generate #{t.name}"
  out = File.binread(t.prerequisites.first)
    .gsub('require "irb"', 'require "irbrc_predefiner"; require "irb"')
  File.binwrite(t.name, out)
end
