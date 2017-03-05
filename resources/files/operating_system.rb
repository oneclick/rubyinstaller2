require "ruby_installer/runtime"

RubyInstaller::Runtime.enable_dll_search_paths

Gem.pre_install do |gem_installer|
  RubyInstaller::Runtime.enable_msys_apps(for_gem_install: true) unless gem_installer.spec.extensions.empty?
end
