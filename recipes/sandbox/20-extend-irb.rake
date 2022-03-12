self.import_files.merge!({
  "resources/files/irbrc_predefiner.rb" => "lib/ruby/site_ruby/#{package.rubylibver}/irbrc_predefiner.rb",
})

file File.join(sandboxdir, "bin/irb.cmd") => File.join(unpackdirmgw, "bin/irb.cmd") do |t|
  puts "generate #{t.name}"
  out = File.binread(t.prerequisites.first)
  mod = out.gsub('require "irb"', 'require "irbrc_predefiner"; require "irb"')
    .gsub("load Gem.activate_bin_path('irb', 'irb', version)", "f = Gem.activate_bin_path('irb', 'irb', version); require 'irbrc_predefiner'; load f")
  raise "irb extension not applicable" if out == mod

  File.binwrite(t.name, mod)
end
