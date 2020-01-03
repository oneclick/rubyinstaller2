# Define files that are imported into the package either from the current working dir or from the rubyinstaller-build gem.

# Ruby-2.7 bundles reline, so that there's no need for rb-readline
if package.rubyver2 < "2.7"
  self.import_files.merge!({
    "resources/files/rbreadline/version.rb" => "lib/ruby/site_ruby/rbreadline/version.rb",
    "resources/files/rbreadline.rb" => "lib/ruby/site_ruby/rbreadline.rb",
    "resources/files/rb-readline.rb" => "lib/ruby/site_ruby/rb-readline.rb",
    "resources/files/readline.rb"  => "lib/ruby/site_ruby/readline.rb",
  })
end
