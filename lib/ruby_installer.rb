module RubyInstaller
  class << self
    class WinApiError < RuntimeError
    end

    def add_dll_directory_winapi(path)
      kernel32 = Fiddle.dlopen('kernel32.dll')
      add_dll_directory = Fiddle::Function.new(
        kernel32['AddDllDirectory'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOIDP
      )
      strutf16 = (path + "\0").encode(Encoding::UTF_16LE)
      strptr = Fiddle::Pointer.malloc(strutf16.bytesize)
      strptr[0, strptr.size] = strutf16
      raise WinApiError, "AddDllDirectory failed" if add_dll_directory.call(strptr).null?

      set_default_dll_directory = Fiddle::Function.new(
        kernel32['SetDefaultDllDirectories'], [Fiddle::TYPE_LONG], Fiddle::TYPE_INT
      )
      # set default search paths to LOAD_LIBRARY_SEARCH_DEFAULT_DIRS
      # to include path added by AddDllDirectory()
      raise WinApiError, "SetDefaultDllDirectories failed" if set_default_dll_directory.call(0x00001000)==0
    end

    @@msys_path = nil
    def msys_path
      @@msys_path ||= case
      when File.directory?("c:/msys64")
        backslachs("c:/msys64")
      when File.directory?("c:/msys32")
        backslachs("c:/msys32")
      else
        key = "SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/{1e909ba1-97d2-41c5-b7ce-a9264f4f723d}"
        Win32::Registry::HKEY_CURRENT_USER.open(backslachs(key)) do |reg|
          reg['InstallLocation']
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

    def backslachs(path)
      path.gsub("/", "\\")
    end

    def add_dll_directory(path)
      require "fiddle"
      begin
        add_dll_directory_winapi(path)
      rescue WinApiError, Fiddle::DLError
        unless ENV['PATH'].include?(path) then
          puts "Temporarily enhancing PATH by #{path}..." if $DEBUG
          ENV['PATH'] = path + ";" + ENV['PATH']
        end
      end
    end

    def enable_mingw_dlls
      add_dll_directory(mingw_bin_path)
    end

    def msys_apps_envvars
      vars = {}
      msys_bin = msys_bin_path
      mingw_bin = mingw_bin_path
      unless ENV['PATH'].include?(msys_bin) then
        vars['PATH'] = mingw_bin + ";" + msys_bin + ";" + ENV['PATH']
      end
      vars['RI_DEVKIT'] = msys_path
      vars['MSYSTEM'] = msystem.upcase
      vars
    end

    def enable_msys_apps
      vars = msys_apps_env
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
      msys_apps_envvars.map do |key, val|
        "#{key}=#{val}"
      end.join("\n")
    end
  end
end
