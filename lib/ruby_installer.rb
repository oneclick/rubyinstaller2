module RubyInstaller
  autoload :DllDirectory, 'ruby_installer/dll_directory'

  MSYS2_INSTALL_KEY = "SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/"
  DEFAULT_MSYS64_PATH = "c:/msys64"
  DEFAULT_MSYS32_PATH = "c:/msys32"

  class << self
    class MsysNotFound < RuntimeError
    end

    @@msys_path = nil
    def msys_path
      @@msys_path ||= case
      when a=ENV['RI_DEVKIT']
        a
      when File.directory?(a=DEFAULT_MSYS64_PATH)
        backslachs(a)
      when File.directory?(a=DEFAULT_MSYS32_PATH)
        backslachs(a)
      else
        require "win32/registry"
        begin
          Win32::Registry::HKEY_CURRENT_USER.open(backslachs(MSYS2_INSTALL_KEY)) do |reg|
            reg.each_key do |subkey|
              subreg = reg.open(subkey)
              if subreg['DisplayName'] =~ /^MSYS2 /
                return subreg['InstallLocation']
              end
            end
          end
        rescue Win32::Registry::Error
        end
        raise MsysNotFound, "MSYS2 could not be found"
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

    @@mingwdir = nil

    # Switch to explicit search paths added by add_dll_directory() and enable MSYS2-MINGW directory this way, if available.
    def enable_dll_search_paths
      @@mingwdir ||= begin
        DllDirectory.set_defaults
        path = mingw_bin_path
        DllDirectory.new(path)
      rescue MsysNotFound
        # We silently ignore this error to allow Ruby installations without MSYS2.
      end
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
      vars['PATH'] = ruby_bin + ";" + mingw_bin + ";" + msys_bin
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
      if (path=vars.delete("PATH")) && !ENV['PATH'].include?(path)
        phrase = "Temporarily enhancing PATH for MSYS/MINGW..."
        if defined?(Gem)
          Gem.ui.say(phrase) if Gem.configuration.verbose
        else
          $stderr.puts phrase if $DEBUG
        end
        ENV['PATH'] = path + ";" + ENV['PATH']
      end
      vars.each do |key, val|
        ENV[key] = val
      end
    end

    def disable_msys_apps(mingwarch=nil)
      vars = with_msys_install_hint{ msys_apps_envvars(mingwarch) }
      if path=vars.delete("PATH")
        ENV['PATH'] = ENV['PATH'].gsub(path + ";", "")
      end
      vars.each do |key, val|
        ENV.delete(key)
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
