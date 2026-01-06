require "io/console"
require "fiddle"
require "fiddle/import"

module RubyInstaller
module Runtime
  class ConsoleUi
    # This class is borrowed from reline
    class Win32API
      DLL = {}
      TYPEMAP = {"0" => Fiddle::TYPE_VOID, "S" => Fiddle::TYPE_VOIDP, "I" => Fiddle::TYPE_LONG}
      POINTER_TYPE = Fiddle::SIZEOF_VOIDP == Fiddle::SIZEOF_LONG_LONG ? 'q*' : 'l!*'

      WIN32_TYPES = "VPpNnLlIi"
      DL_TYPES = "0SSI"

      def initialize(dllname, func, import, export = "0", calltype = :stdcall)
        @proto = [import].join.tr(WIN32_TYPES, DL_TYPES).sub(/^(.)0*$/, '\1')
        import = @proto.chars.map {|win_type| TYPEMAP[win_type.tr(WIN32_TYPES, DL_TYPES)]}
        export = TYPEMAP[export.tr(WIN32_TYPES, DL_TYPES)]
        calltype = Fiddle::Importer.const_get(:CALL_TYPE_TO_ABI)[calltype]

        handle = DLL[dllname] ||= begin
          Fiddle.dlopen(dllname)
        rescue Fiddle::DLError
          raise unless File.extname(dllname).empty?
          Fiddle.dlopen(dllname + ".dll")
        end

        @func = Fiddle::Function.new(handle[func], import, export, calltype)
      rescue Fiddle::DLError => e
        raise LoadError, e.message, e.backtrace
      end

      def call(*args)
        import = @proto.split("")
        args.each_with_index do |x, i|
          args[i], = [x == 0 ? nil : +x].pack("p").unpack(POINTER_TYPE) if import[i] == "S"
          args[i], = [x].pack("I").unpack("i") if import[i] == "I"
        end
        ret, = @func.call(*args)
        return ret || 0
      end
    end

    class ButtonMatrix
      include Colors

      attr_accessor :selected
      attr_accessor :headline

      def initialize(ncols: 3)
        @ncols = ncols
        @boxes = []
        @con = IO.console
        @selected = 0
        @headline = ""
        enable_colors
      end

      Box = Data.define :text, :action
      def add_button(text, &action)
        @boxes << Box.new(text, action)
      end

      def cursor(direction)
        case direction
        when :left
          @selected -= 1 if @selected > 0
        when :up
          @selected -= @ncols if @selected - @ncols >= 0
        when :right
          @selected += 1 if @selected + 1 < @boxes.size
        when :down
          @selected += @ncols if @selected + @ncols < @boxes.size
        end
      end

      def select
        @boxes[@selected].action.call
      end

      def click(x, y)
        s = @slines&.[](y)&.[](x)
        if s
          self.selected = s
          true
        end
      end

      BUTTON_BORDERS = {
        thin:   "┌─┐" +
                "│ │" +
                "└─┘" ,
        fat:    "┏━┓" +
                "┃ ┃" +
                "┗━┛" ,
        double: "╔═╗" +
                "║ ║" +
                "╚═╝" ,
      }

      private def box_border(ncol, nrow)
        box_idx = ncol + nrow * @ncols
        selected = box_idx == @selected
        border = BUTTON_BORDERS[selected ? :double : :thin]
        border = border.each_char.map do |ch|
          selected ? green(ch) : blue(ch)
        end
        box = @boxes[box_idx]&.text
        return box, border, box_idx
      end

      # Paint the boxes
      def repaint(width: @con.winsize[1], height: @con.winsize[0])
        headroom = headline.size > 0 ? (headline.size + width - 1) / width : 0  # roughly
        obw = (width.to_f / @ncols).floor
        spw = obw - 4
        nrows = (@boxes.size.to_f / @ncols).ceil
        obh = ((height - headroom).to_f / nrows).floor
        sph = obh - 2
        sph = 1 if sph < 1
        line = +""
        slines = [[]]
        nrows.times do |nrow|
          @ncols.times do |ncol|
            box, border, box_idx = box_border(ncol, nrow)
            if box
              line += " #{border[0]}" + "#{border[1]}" * spw + "#{border[2]} "
              slines.last.append(*([box_idx] * obw))
            end
          end
          line += "\n"
          slines << []
          sph.times do |spy|
            @ncols.times do |ncol|
              box, border, box_idx = box_border(ncol, nrow)
              if box
                text_lines = box.lines.map(&:chomp)
                text_pos = spy - (sph - text_lines.size) / 2
                text_line = text_lines[text_pos] if text_pos >= 0
                text_line ||= ""
                spl = (spw - text_line.size) / 2
                spr = spw - spl - text_line.size
                spl = 0 if spl < 0
                spr = 0 if spr < 0
                line += " #{border[3]}" + " " * spl + text_line + " " * spr + "#{border[5]} "
                slines.last.append(*([box_idx] * obw))
              end
            end
            line += "\n"
            slines << []
          end
          @ncols.times do |ncol|
            box, border, box_idx = box_border(ncol, nrow)
            if box
              line += " #{border[6]}" + "#{border[7]}" * spw + "#{border[8]} "
              slines.last.append(*([box_idx] * obw))
            end
          end
          line += "\n"
          slines << []
        end
        @con.write "\e[1;1H" "\e[2J"
        print "#{headline}"
        print @con.cursor.last == 0 ? line.chomp : "\n#{line.chomp}"
        @slines = slines
      end
    end

    STD_INPUT_HANDLE = -10
    STD_OUTPUT_HANDLE = -11
    ENABLE_PROCESSED_INPUT = 0x0001
    ENABLE_MOUSE_INPUT = 0x0010
    ENABLE_QUICK_EDIT_MODE = 0x0040
    ENABLE_EXTENDED_FLAGS = 0x0080
    ENABLE_VIRTUAL_TERMINAL_INPUT = 0x200

    attr_accessor :widget

    def initialize
      @GetStdHandle = Win32API.new('kernel32', 'GetStdHandle', ['L'], 'L')
      @GetConsoleMode = Win32API.new('kernel32', 'GetConsoleMode', ['L', 'P'], 'L')
      @SetConsoleMode = Win32API.new('kernel32', 'SetConsoleMode', ['L', 'L'], 'L')

      @hConsoleHandle = @GetStdHandle.call(STD_INPUT_HANDLE)
      @ev_r, @ev_w = IO.pipe.map(&:binmode)
      @read_request_queue = Thread::Queue.new

      set_consolemode

      register_term_size_change
      register_stdin

      at_exit do
        unset_consolemode
      end
    end

    def clear_screen
      IO.console.write "\e[H" "\e[2J"
    end

    def set_consolemode
      @base_console_input_mode = getconsolemode
      setconsolemode(ENABLE_PROCESSED_INPUT | ENABLE_MOUSE_INPUT | ENABLE_EXTENDED_FLAGS | ENABLE_VIRTUAL_TERMINAL_INPUT)
    end

    def unset_consolemode
      if @base_console_input_mode
IO.console.write "."
        setconsolemode(@base_console_input_mode | ENABLE_EXTENDED_FLAGS)
IO.console.write "+"
        @base_console_input_mode = nil
        if block_given?
          begin
            yield
          ensure
            set_consolemode
          end
        end
      end
    end

    # Calling Win32API with console handle is reported to fail after executing some external command.
    # We need to refresh console handle and retry the call again.
    private def call_with_console_handle(win32func, *args)
      val = win32func.call(@hConsoleHandle, *args)
      return val if val != 0

      @hConsoleHandle = @GetStdHandle.call(STD_INPUT_HANDLE)
      win32func.call(@hConsoleHandle, *args)
    end

    private def getconsolemode
      mode = +"\0\0\0\0"
      call_with_console_handle(@GetConsoleMode, mode)
      mode.unpack1('L')
    end

    private def setconsolemode(mode)
      call_with_console_handle(@SetConsoleMode, mode)
    end

    private def register_term_size_change
      if RUBY_PLATFORM =~ /mingw|mswin/
        con = IO.console
        old_size = con.winsize
        Thread.new do
          loop do
            new_size = con.winsize
            if old_size != new_size
              old_size = new_size
              @ev_w.write "\x01"
            end
            sleep 1
          end
        end
      else
        Signal.trap('SIGWINCH') do
          @ev_w.write "\x01"
        end
      end
    end

    private def register_stdin
      Thread.new do
        str = +""
        @read_request_queue.shift
        c = IO.console
        while char=c.read(1)
          str << char
          next if !str.valid_encoding? ||
              str == "\e" ||
              str == "\e[" ||
              str == "\xE0" ||
              str.match(/\A\e\x5b<[0-9;]*\z/)

          @ev_w.write [2, str.size, str].pack("CCa*")
          str = +""
          @read_request_queue.shift
        end
      end
    end

    private def request_read
      @read_request_queue.push true
    end

    private def handle_key_input(str)
      case str
      when "\e[D", "\xE0K".b # cursor left
        widget.cursor(:left)
      when "\e[A", "\xE0H".b # cursor up
        widget.cursor(:up)
      when "\e[C", "\xE0M".b # cursor right
        widget.cursor(:right)
      when "\e[B", "\xE0P".b # cursor down
        widget.cursor(:down)
      when "\r" # enter
        unset_consolemode do
          widget.select
        end
      when /\e\x5b<0;(\d+);(\d+)m/ # Mouse left button up
        if widget.click($1.to_i - 1, $2.to_i - 2)
          widget.repaint
          unset_consolemode do
            widget.select
          end
        end
      when /\e\x5b<\d+;(\d+);(\d+)[Mm]/ # other mouse events
        return # no repaint
      end
      widget.repaint
    end

    private def main_loop
      str = +""
      request_read
      while char=@ev_r.read(1)
        case char
        when "\x01"
          widget.repaint
        when "\x02"
          strlen = @ev_r.read(1).unpack1("C")
          str = @ev_r.read(strlen)

          handle_key_input(str)
        else
          raise "unexpected event: #{char.inspect}"
        end
        request_read
      end
    end

    def run!
      widget.repaint
      main_loop
    end
  end
end
end

if $0 == __FILE__
  app = RubyInstaller::Runtime::ConsoleUi.new
  bm = RubyInstaller::Runtime::ConsoleUi::ButtonMatrix.new ncols: 3
  bm.add_button "text1\nabc" do
    p :button_1
    exit
  end
  bm.add_button "text2" do
    p :button_2
    exit
  end
  bm.add_button "text3\nabc\noollla\n text3\nabc\noollla" do
    p :button_3
    exit
  end
  bm.add_button "text4\ndef" do
    p :button_4
    exit
  end
  bm.add_button "text5\nabc" do
    p :button_5
    exit
  end
  app.widget = bm
  app.run!
end
