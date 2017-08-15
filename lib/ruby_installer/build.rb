module RubyInstaller
module Build
  autoload :CaCertFile, 'ruby_installer/build/ca_cert_file'
  autoload :Colors, 'ruby_installer/build/colors'
  autoload :ComponentsInstaller, 'ruby_installer/build/components_installer'
  autoload :DllDirectory, 'ruby_installer/build/dll_directory'
  autoload :ErbCompiler, 'ruby_installer/build/erb_compiler'
  autoload :Gems, 'ruby_installer/build/gems'
  autoload :Msys2Installation, 'ruby_installer/build/msys2_installation'
  autoload :GEM_VERSION, 'ruby_installer/build/gem_version'
  autoload :Task, 'ruby_installer/build/task'
  autoload :Openstruct, 'ruby_installer/build/openstruct'
  autoload :Release, 'ruby_installer/build/release'
  autoload :Utils, 'ruby_installer/build/utils'

  module Components
    autoload :Base, 'ruby_installer/build/components/base'
  end

  require 'ruby_installer/build/singleton'
  BuildOrRuntime = self
end
end
