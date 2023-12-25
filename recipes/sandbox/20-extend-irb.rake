# This adds some logic to define a .irbrc to enable history saving and completion.
# These features are enabled by default since ruby-3.3 and require paths have been changed.
# Therefore the job on later versions is inverted to remove the .irbrc when unchanged.

self.import_files.merge!({
  "resources/files/irbrc_predefiner.rb" => "lib/ruby/site_ruby/#{package.rubylibver}/irbrc_predefiner.rb",
})

irbbin = package.rubyver2 < "3.1" ? "bin/irb.cmd" : "bin/irb"
file File.join(sandboxdir, irbbin) => File.join(unpackdirmgw, irbbin) do |t|
  puts "generate #{t.name}"
  out = File.binread(t.prerequisites.first)
  mod = out.gsub('require "irb"', 'require "irbrc_predefiner"; require "irb"')
    .gsub("load Gem.activate_bin_path('irb', 'irb', version)", "f = Gem.activate_bin_path('irb', 'irb', version); require 'irbrc_predefiner'; load f")
  raise "irb extension not applicable" if out == mod

  File.binwrite(t.name, mod)
end
