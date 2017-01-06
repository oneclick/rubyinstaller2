require "ruby_installer"

Gem.pre_install do |gem_installer|
  RubyInstaller.enable_msys_apps unless gem_installer.spec.extensions.empty?
end

RubyInstaller.enable_mingw_dlls
