require "ruby_installer"

Gem.pre_install do |gem_installer|
  RubyInstaller.enable_msys_apps(for_gem_install: true) unless gem_installer.spec.extensions.empty?
end

RubyInstaller.enable_dll_search_paths
