require "ruby_installer/runtime"

RubyInstaller::Runtime.enable_dll_search_paths

Gem.pre_install do |gem_installer|
  RubyInstaller::Runtime.enable_msys_apps(for_gem_install: true) unless gem_installer.spec.extensions.empty?

  if !gem_installer.options || !gem_installer.options[:ignore_dependencies] || gem_installer.options[:bundler_expected_checksum]
    [['msys2_dependencies'      , :install_packages      ],
     ['msys2_mingw_dependencies', :install_mingw_packages]].each do |metakey, func|

      if deps=gem_installer.spec.metadata[metakey]
        begin
          RubyInstaller::Runtime.msys2_installation.send(func, deps.split(" "), verbose: Gem.configuration.verbose)
        rescue RubyInstaller::Runtime::Msys2Installation::CommandError => err
          Gem.ui.say(err.to_s)
        end
      end
    end
  end
end
