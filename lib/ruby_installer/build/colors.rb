module RubyInstaller
module Build # Use for: Build, Runtime
  module Colors
    # Start an escape sequence
    ESC = "\e["

    # End the escape sequence
    NND = "#{ESC}0m"

    ColorMap = {
      black: 0,
      red: 1,
      green: 2,
      yellow: 3,
      blue: 4,
      magenta: 5,
      cyan: 6,
      white: 7,
    }

    module_function

    ColorMap.each do |color, code|
      define_method(color) do |string|
        colored(code, string)
      end
    end

    def initialize(*_, **_)
      super
      @colors_on = nil
    end

    def colored(color, string)
      @colors_on = $stdout.tty? if @colors_on.nil?
      if @colors_on
        c = ColorMap[color] || color
        "#{ESC}#{30+c}m#{string}#{NND}"
      else
        string.dup
      end
    end

    def enable_colors
      @colors_on = true
    end

    def disable_colors
      @colors_on = false
    end
  end
end
end
