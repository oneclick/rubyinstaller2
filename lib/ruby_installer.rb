module RubyInstaller
  autoload :DllDirectory, 'ruby_installer/dll_directory'

  class << self
    class WinApiError < RuntimeError
    end
    class MsysNotFound < RuntimeError
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

    def mingw_bin_path(mingwarch=nil)
      backslachs( File.join(msys_path, mingwarch || msystem, "bin") )
    end

    private def backslachs(path)
      path.gsub("/", "\\")
    end

    # Add +path+ as a search path for DLLs
    #
    # This can be used to allow ruby extension files (typically named +<extension>.so+ ) to import dependent DLLs from another directory.
    #
    # If this method is called with a block, the path is temporary added until the block is finished.
    # The method returns a DllDirectory instance, when called without a block.
    # It can be used to remove the directory later.
    def add_dll_directory(path, &block)
      DllDirectory.new(path, &block)
    end

    # Switch to explicit search paths added by add_dll_directory() and enable MSYS2-MINGW directory this way, if available.
    def enable_dll_search_paths
      DllDirectory.set_defaults
      # We silently ignore this error to allow Ruby installations without MSYS2.
      path = mingw_bin_path rescue MsysNotFound
      DllDirectory.new(path) if path
    end

    private def ruby_bin_dir
      require "rbconfig"
      backslachs( File.join(RbConfig::TOPDIR, "bin") )
    end

    private def msys_apps_envvars(mingwarch=nil)
      vars = {}
      msys_bin = msys_bin_path
      mingw_bin = mingw_bin_path(mingwarch)
      ruby_bin = ruby_bin_dir
      unless ENV['PATH'].include?(msys_bin) && ENV['PATH'].include?(mingw_bin)
        vars['PATH'] = ruby_bin + ";" + mingw_bin + ";" + msys_bin + ";" + ENV['PATH'].gsub(";"+ruby_bin, "")
      end
      vars['RI_DEVKIT'] = msys_path
      vars['MSYSTEM'] = (mingwarch || msystem).upcase
      vars
    end

    private def with_msys_install_hint
      begin
        yield
      rescue MsysNotFound
        $stderr.puts "MSYS2 could not be found."
        $stderr.puts "Please download and install MSYS2 from https://msys2.github.io/"
        exit 1
      end
    end

    # Add MSYS2 to the PATH and set other environment variables required to run MSYS2.
    #
    # This method tries to find a MSYS2 installation or exits with a description how to install MSYS2.
    #
    # +mingwarch+ should be either 'mingw32', 'mingw64' or nil.
    # In the latter case the mingw architecture is used based on the architecture of the running Ruby process.
    def enable_msys_apps(mingwarch=nil)
      vars = with_msys_install_hint{ msys_apps_envvars(mingwarch) }
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

    # This method is used for rubydevkit command.
    def msys_apps_envvars_for_cmd
      vars = with_msys_install_hint{ msys_apps_envvars }
      vars.map do |key, val|
        "#{key}=#{val}"
      end.join("\n")
    end
  end
end
