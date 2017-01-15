module RubyInstaller
  class << self
    class WinApiError < RuntimeError
    end
    class MsysNotFound < RuntimeError
    end

    private def add_dll_directory_winapi(path)
      kernel32 = Fiddle.dlopen('kernel32.dll')
      add_dll_directory = Fiddle::Function.new(
        kernel32['AddDllDirectory'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOIDP
      )
      strutf16 = (path + "\0").encode(Encoding::UTF_16LE)
      strptr = Fiddle::Pointer.malloc(strutf16.bytesize)
      strptr[0, strptr.size] = strutf16
      handle = add_dll_directory.call(strptr)
      raise WinApiError, "AddDllDirectory failed" if handle.null?

      set_default_dll_directory = Fiddle::Function.new(
        kernel32['SetDefaultDllDirectories'], [Fiddle::TYPE_LONG], Fiddle::TYPE_INT
      )
      # set default search paths to LOAD_LIBRARY_SEARCH_DEFAULT_DIRS
      # to include path added by AddDllDirectory()
      raise WinApiError, "SetDefaultDllDirectories failed" if set_default_dll_directory.call(0x00001000)==0
      handle
    end

    @@msys_path = nil
    def msys_path
      @@msys_path ||= case
      when File.directory?("c:/msys64")
        backslachs("c:/msys64")
      when File.directory?("c:/msys32")
        backslachs("c:/msys32")
      else
        require "win32/registry"
        begin
          key = "SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/{1e909ba1-97d2-41c5-b7ce-a9264f4f723d}"
          Win32::Registry::HKEY_CURRENT_USER.open(backslachs(key)) do |reg|
            reg['InstallLocation']
          end
        rescue Win32::Registry::Error
          raise MsysNotFound, "MSYS2 could not be found"
        end
      end
    end

    def msys_bin_path
      backslachs( File.join(msys_path, "/usr/bin") )
    end

    def msystem
      RUBY_PLATFORM=~/x64/ ? 'MINGW64' : 'MINGW32'
    end

    def mingw_bin_path
      backslachs( File.join(msys_path, msystem, "bin") )
    end

    private def backslachs(path)
      path.gsub("/", "\\")
    end

    class DllDirectory
      attr_reader :path

      def initialize(path, handle)
        @path = path
        @handle = handle
      end

      def remove
        if @handle
          kernel32 = Fiddle.dlopen('kernel32.dll')
          remove_dll_directory = Fiddle::Function.new(
            kernel32['RemoveDllDirectory'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT
          )
          raise WinApiError, "RemoveDllDirectory failed" if remove_dll_directory.call(@handle) == 0
        elsif @path
          ENV['PATH'] = ENV['PATH'].sub(@path + ";", "")
        end
      end
    end

    # Add +path+ as a search path for DLLs
    #
    # This can be used to allow ruby extension files (typically named +<extension>.so+ ) to import dependent DLLs from another directory.
    #
    # If this method is called with a block, the path is temporary added until the block is finished.
    # The method returns a DllDirectory instance, when called without a block.
    # It can be used to remove the directory later.
    def add_dll_directory(path)
      path = File.expand_path(path)

      require "fiddle"
      handle = begin
        # Prefer Winapi function AddDllDirectory(), which requires
        # Windows 7 with KB2533623 or newer.
        hand = add_dll_directory_winapi(path)
        DllDirectory.new(path, hand)
      rescue WinApiError, Fiddle::DLError
        # For older systems fall back to the legacy method of using PATH
        # environment variable.
        if ENV['PATH'].include?(path)
          DllDirectory.new(nil, nil)
        else
          puts "Temporarily enhancing PATH by #{path}..." if $DEBUG
          ENV['PATH'] = path + ";" + ENV['PATH']
          DllDirectory.new(path, nil)
        end
      end
      return handle unless block_given?
      begin
        yield handle
      ensure
        handle.remove
      end
    end

    def enable_mingw_dlls
      begin
        add_dll_directory(mingw_bin_path)
      rescue MsysNotFound
        # We silently ignore this error to allow Ruby installations without MSYS2.
      end
    end

    def ruby_bin_dir
      require "rbconfig"
      backslachs( File.join(RbConfig::TOPDIR, "bin") )
    end

    def msys_apps_envvars
      vars = {}
      msys_bin = msys_bin_path
      mingw_bin = mingw_bin_path
      ruby_bin = ruby_bin_dir
      unless ENV['PATH'].include?(msys_bin) then
        vars['PATH'] = ruby_bin + ";" + mingw_bin + ";" + msys_bin + ";" + ENV['PATH'].gsub(";"+ruby_bin, "")
      end
      vars['RI_DEVKIT'] = msys_path
      vars['MSYSTEM'] = msystem.upcase
      vars
    end

    def with_msys_install_hint
      begin
        yield
      rescue MsysNotFound
        $stderr.puts "MSYS2 could not be found."
        $stderr.puts "Please download and install MSYS2 from https://msys2.github.io/"
        exit 1
      end
    end

    def enable_msys_apps
      vars = with_msys_install_hint{ msys_apps_envvars }
      if vars["PATH"]
        phrase = "Temporarily enhancing PATH for MSYS/MINGW..."
        if defined?(Gem)
          Gem.ui.say(phrase) if Gem.configuration.verbose
        else
          puts phrase if $DEBUG
        end
      end
      vars.each do |key, val|
        ENV[key] = val
      end
    end

    def msys_apps_envvars_for_cmd
      vars = with_msys_install_hint{ msys_apps_envvars }
      vars.map do |key, val|
        "#{key}=#{val}"
      end.join("\n")
    end
  end
end
