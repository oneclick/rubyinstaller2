# :DK-BEG: override 'gem install' to enable RubyInstaller DevKit usage
Gem.pre_install do |gem_installer|
  load 'devkit.rb' unless gem_installer.spec.extensions.empty?
end
# :DK-END:
