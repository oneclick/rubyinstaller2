require "fiddle"

module RubyInstaller
  # :nodoc:
  class DllDirectory
    class Error < RuntimeError
    end
    class WinApiError < Error
    end

    KERNEL32 = Fiddle.dlopen('kernel32.dll')
    begin
      SetDefaultDllDirectories = Fiddle::Function.new(
        KERNEL32['SetDefaultDllDirectories'], [Fiddle::TYPE_LONG], Fiddle::TYPE_INT
      )

      AddDllDirectory = Fiddle::Function.new(
        KERNEL32['AddDllDirectory'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOIDP
      )

      RemoveDllDirectory = Fiddle::Function.new(
        KERNEL32['RemoveDllDirectory'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT
      )
    rescue Fiddle::DLError
      @@add_dll_dir_available = false
    else
      @@add_dll_dir_available = ENV['RI_FORCE_PATH_FOR_DLL'] == '1' ? false : true
    end

    attr_reader :path

    # Set default search paths to the application directory (where ruby.exe resides) and to paths that are added per DllDirectory.new().
    # It disables the PATH environment variable for DLL search.
    #
    # This methos is usually called while RubyInstaller startup.
    def self.set_defaults
      if @@add_dll_dir_available
        set_default_dll_directories_winapi
      end
    end

    def initialize(path)
      path = File.expand_path(path)

      if @@add_dll_dir_available
        # Prefer Winapi function AddDllDirectory(), which requires Windows 7 with KB2533623 or newer.
        self.class.set_default_dll_directories_winapi
        @handle = self.class.add_dll_directory_winapi(path)
        @path = path
      else
        raise Error, "invalid path #{path}" unless File.directory?(path)
        # For older systems fall back to the legacy method of using PATH environment variable.
        unless ENV['PATH'].include?(path)
          $stderr.puts "Temporarily enhancing PATH by #{path}..." if $DEBUG
          ENV['PATH'] = path + ";" + ENV['PATH']
        end
        @handle = nil
        @path = path
      end
      return unless block_given?
      begin
        yield self
      ensure
        remove
      end
    end

    # Set default search paths to LOAD_LIBRARY_SEARCH_DEFAULT_DIRS to include path added by add_dll_directory_winapi() and exclude paths set per PATH environment variable.
    def self.set_default_dll_directories_winapi
      raise WinApiError, "SetDefaultDllDirectories failed" if SetDefaultDllDirectories.call(0x00001000)==0
    end

    def self.add_dll_directory_winapi(path)
      strutf16 = (path + "\0").encode(Encoding::UTF_16LE)
      strptr = Fiddle::Pointer.malloc(strutf16.bytesize)
      strptr[0, strptr.size] = strutf16
      handle = AddDllDirectory.call(strptr)
      raise WinApiError, "AddDllDirectory failed for #{path}" if handle.null?
      handle
    end

    def remove
      if @handle
        raise WinApiError, "RemoveDllDirectory failed for #{@path}" if RemoveDllDirectory.call(@handle) == 0
      elsif @path
        ENV['PATH'] = ENV['PATH'].sub(@path + ";", "")
      end
    end
  end
end
