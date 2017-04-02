module RubyInstaller
  autoload :Runtime, 'ruby_installer/runtime'

  class << self
    extend Gem::Deprecate

    # See RubyInstaller::Runtime.add_dll_directory
    def add_dll_directory(path, &block)
      Runtime.add_dll_directory(path, &block)
    end

    deprecate :add_dll_directory, %q["require 'ruby_installer/runtime'; RubyInstaller::Runtime.add_dll_directory"], 2017, 8
  end
end
