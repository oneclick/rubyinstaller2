module RubyInstaller
  autoload :Runtime, 'ruby_installer/runtime'

  # See RubyInstaller::Runtime.add_dll_directory
  def self.add_dll_directory(path, &block)
    Runtime.add_dll_directory(path, &block)
  end
end
