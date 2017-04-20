gem_cmd = File.join(sandboxdir, "bin/gem.cmd")
package.install_gems.each do |gem|
  gemspec = File.join(sandboxdir, "lib/ruby/gems/#{package.rubyver2}.0/specifications/#{gem}.gemspec")
  file gemspec do
    with_env(GEM_HOME: nil, GEM_PATH: nil, RUBYOPT: nil, RUBYLIB: nil) do
      /(?<gem_name>.*)-(?<gem_ver>.*)/ =~ gem || raise(ArgumentError, "invalid gem name #{gem.inspect}")
      RubyInstaller::Build::Gems.install(gem_name, gem_version: gem_ver, gem_cmd: gem_cmd)
    end
  end
  self.sandboxfiles << gemspec
end
