self.gem_bin_wrappers.each do |gem, files|
  wrappers = files.map{|w| File.join(sandboxdir, "bin", w) }

  gemspec = File.join(sandboxdir, "lib/ruby/gems/2.4.0/specifications/#{gem}.gemspec")
  wrappers.each do |wrapper|
    file wrapper => gemspec
  end

  self.sandboxfiles += wrappers
end
