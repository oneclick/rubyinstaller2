Gem::Specification.new do |s|
  s.name = 'testgem'
  s.version = '1.0.0'
  s.author = 'Lars Kanis'
  s.email = 'lars@greiz-reinsdorf.de'
  s.homepage = 'https://github.com/larskanis/rubyinstaller2'
  s.summary = 'RubyInstaller2 testgem'
  s.description = 'A gem to test gem installation with RubyInstaller2'
  s.files = `git ls-files`.split("\n")
  s.extensions << 'ext/extconf.rb'
  s.license = 'BSD-3-Clause'
  s.require_paths << 'lib'
  s.bindir = "exe"
  s.executables = ["testgem-exe"]
  s.required_ruby_version = '>= 2.1.0'
  s.metadata['msys2_dependencies'] = 'ed>=1.0'
  s.metadata['msys2_mingw_dependencies'] = 'libguess>=1.0 gcc>=8.0'
end
