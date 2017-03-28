require "ruby_installer/runtime"

RubyInstaller::Runtime.enable_dll_search_paths

Gem.pre_install do |gem_installer|
  RubyInstaller::Runtime.enable_msys_apps(for_gem_install: true) unless gem_installer.spec.extensions.empty?

  deps = gem_installer.spec.metadata['msys2_dependencies']
  if deps && !gem_installer.options[:ignore_dependencies]
    begin
      RubyInstaller::Runtime.msys2_installation.install_mingw_packages(deps.split(" "), verbose: Gem.configuration.verbose)
    rescue RubyInstaller::Runtime::Msys2Installation::CommandError => err
      Gem.ui.say(err.to_s)
    end
  end
end
