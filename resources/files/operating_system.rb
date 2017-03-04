ripath = Dir[File.join(Gem.dir, "gems/rubyinstaller-*/lib")].sort.last or
  raise(LoadError, "Unable to find rubyinstaller gem")
$LOAD_PATH << ripath

require "ruby_installer"
RubyInstaller.rubygems_integration
