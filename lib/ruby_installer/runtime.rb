module RubyInstaller
module Runtime
  autoload :Colors, 'ruby_installer/runtime/colors'
  autoload :ComponentsInstaller, 'ruby_installer/runtime/components_installer'
  autoload :DllDirectory, 'ruby_installer/runtime/dll_directory'
  autoload :Msys2Installation, 'ruby_installer/runtime/msys2_installation'
  autoload :Ridk, 'ruby_installer/runtime/ridk'
  autoload :PACKAGE_VERSION, 'ruby_installer/runtime/package_version'
  autoload :GIT_COMMIT, 'ruby_installer/runtime/package_version'

  module Components
    autoload :Base, 'ruby_installer/runtime/components/base'
  end

  require 'ruby_installer/runtime/singleton'
  BuildOrRuntime = self
end
end
