Gem::Specification.new do |s|
  s.name = 'testgem2'
  s.version = '1.0.0'
  s.author = 'Lars Kanis'
  s.email = 'lars@greiz-reinsdorf.de'
  s.homepage = 'https://github.com/larskanis/rubyinstaller2'
  s.summary = 'RubyInstaller2 testgem'
  s.description = 'A second gem to test gem installation with RubyInstaller2'
  s.files = `git ls-files`.split("\n")
  s.extensions << 'ext2/extconf2.rb'
  s.license = 'BSD-3-Clause'
  s.require_paths << 'lib'
  s.required_ruby_version = '>= 2.1.0'
  s.metadata['msys2_mingw_dependencies'] = 'libidn2'
end
