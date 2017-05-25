module RubyInstaller
module Build # Use for: Build, Runtime
module Components
class Base < Rake::Task
  include Colors

  attr_accessor :task_index
  attr_writer :msys
  attr_accessor :pacman_args

  def self.depends
    []
  end

  def initialize(*_)
    @msys = nil
    enable_colors
    super
  end

  def msys
    @msys ||= BuildOrRuntime.msys2_installation
  end

  # This is extracted from https://github.com/larskanis/shellwords
  def shell_escape(str)
    str = str.to_s

    # An empty argument will be skipped, so return empty quotes.
    return '""' if str.empty?

    str = str.dup

    str.gsub!(/((?:\\)*)"/){ "\\" * ($1.length*2) + "\\\"" }
    if str =~ /\s/
      str.gsub!(/(\\+)\z/){ "\\" * ($1.length*2) }
      str = "\"#{str}\""
    end

    return str
  end

  def shell_join(array)
    array.map { |arg| shell_escape(arg) }.join(' ')
  end

  def run_verbose(*args)
    puts "> #{ cyan(shell_join(args)) }"
    system(*args)
  end
end
end
end
end
