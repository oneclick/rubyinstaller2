require "stringio"
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
        @con.write "\e[H" "\e[J"
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
    KEY_EVENT = 0x01
    MOUSE_EVENT = 0x02
    WINDOW_BUFFER_SIZE_EVENT = 0x04

    attr_accessor :widget

    def initialize
      @GetStdHandle = Win32API.new('kernel32', 'GetStdHandle', ['L'], 'L')
      @GetConsoleMode = Win32API.new('kernel32', 'GetConsoleMode', ['L', 'P'], 'L')
      @SetConsoleMode = Win32API.new('kernel32', 'SetConsoleMode', ['L', 'L'], 'L')
      @ReadConsoleInputW = Win32API.new('kernel32', 'ReadConsoleInputW', ['L', 'P', 'L', 'P'], 'L')
      @GetConsoleScreenBufferInfo = Win32API.new('kernel32', 'GetConsoleScreenBufferInfo', ['L', 'P'], 'L')

      @hConsoleHandle = @GetStdHandle.call(STD_INPUT_HANDLE)
      @hConsoleOutHandle = @GetStdHandle.call(STD_OUTPUT_HANDLE)

      @mouse_state = 0
      @old_winsize = IO.console.winsize
      set_consolemode

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
        setconsolemode(@base_console_input_mode | ENABLE_EXTENDED_FLAGS)
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

    def get_console_screen_buffer_info
      # CONSOLE_SCREEN_BUFFER_INFO
      # [ 0,2] dwSize.X
      # [ 2,2] dwSize.Y
      # [ 4,2] dwCursorPositions.X
      # [ 6,2] dwCursorPositions.Y
      # [ 8,2] wAttributes
      # [10,2] srWindow.Left
      # [12,2] srWindow.Top
      # [14,2] srWindow.Right
      # [16,2] srWindow.Bottom
      # [18,2] dwMaximumWindowSize.X
      # [20,2] dwMaximumWindowSize.Y
      csbi = 0.chr * 22
      if @GetConsoleScreenBufferInfo.call(@hConsoleOutHandle, csbi) != 0
        # returns [width, height, x, y, attributes, left, top, right, bottom]
        csbi.unpack("s9")
      else
        return nil
      end
    end

    private def winsize_changed?
      con = IO.console
      new_size = con.winsize
      if @old_winsize != new_size
        @old_winsize = new_size
        true
      else
        false
      end
    end

    def read_input_event
      # Wait for reception of at least one event
      input_records = 0.chr * 20 * 1
      read_event = 0.chr * 4

      if @ReadConsoleInputW.(@hConsoleHandle, input_records, 1, read_event) != 0
        read_events = read_event.unpack1('L')
        0.upto(read_events-1) do |idx|
          input_record = input_records[idx * 20, 20]
          event = input_record[0, 2].unpack1('s*')
          case event
          when KEY_EVENT
            key_down = input_record[4, 4].unpack1('l*')
            repeat_count = input_record[8, 2].unpack1('s*')
            virtual_key_code = input_record[10, 2].unpack1('s*')
            virtual_scan_code = input_record[12, 2].unpack1('s*')
            char_code = input_record[14, 2].unpack1('S*')
            control_key_state = input_record[16, 2].unpack1('S*')
            is_key_down = key_down.zero? ? false : true
            if is_key_down
              # p [repeat_count, virtual_key_code, virtual_scan_code, char_code, control_key_state]

              return char_code.chr
            end
          when MOUSE_EVENT
            click_x, click_y, state = input_record[4, 8].unpack("ssL")
            if @mouse_state != state
              # click state changed
              @mouse_state = state
              csbi = get_console_screen_buffer_info || raise("error at GetConsoleScreenBufferInfo")
              click_y -= csbi[6]
              # p mouse: [click_x, click_y, state]

              if state == 1
                # mouse button down
                return "\e\x5b<0;#{click_x};#{click_y}M"
              else
                # mouse button up
                return "\e\x5b<0;#{click_x};#{click_y}m"
              end
            end
          when WINDOW_BUFFER_SIZE_EVENT
            return :winsize_changed
          end
        end
      end
      false
    end

    private def windows_terminal?
      !!ENV["WT_SESSION"]
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
      when /\A\e\x5b<0;(\d+);(\d+)m\z/ # Mouse left button up
        if widget.click($1.to_i - 1, $2.to_i - 2)
          widget.repaint
          unset_consolemode do
            widget.select
          end
        end
      when /\A\e\x5b<\d+;(\d+);(\d+)[Mm]\z/ # other mouse events
        return # no repaint
      end
      widget.repaint
    end

    private def main_loop
      str = +""
      console_buffer = StringIO.new
      loop do
        if windows_terminal?
          c = IO.console

          rs, = IO.select([c], [], [], 0.5)
          if rs
            char = c.read(1)
            break unless char
          else
            # timeout -> check windows size change
            widget.repaint if winsize_changed?
          end
        else
          if console_buffer.eof?
            input = read_input_event
            if input == :winsize_changed
              widget.repaint if winsize_changed?
            elsif input
              console_buffer = StringIO.new(input)
            end
          end
          char = console_buffer.read(1)
        end
        next unless char
        str << char

        next if !str.valid_encoding? ||
              str == "\e" ||
              str == "\e[" ||
              str == "\xE0" ||
              str.match(/\A\e\x5b<[0-9;]*\z/)

        handle_key_input(str)
        str = +""
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
