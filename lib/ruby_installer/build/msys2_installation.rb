require "rbconfig"

module RubyInstaller
module Build # Use for: Build, Runtime
  # :nodoc:
  class Msys2Installation
    MSYS2_INSTALL_KEY = "SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/"
    MSYS2_INSTALL_KEY_WOW = "SOFTWARE/WOW6432Node/Microsoft/Windows/CurrentVersion/Uninstall/"

    include Colors

    class MsysNotFound < RuntimeError
    end
    class CommandError < RuntimeError
    end

    attr_reader :mingwdir
    attr_reader :mingwarch
    attr_reader :mingw_package_prefix
    attr_reader :ruby_bin_dir

    def initialize(msys_path: nil, mingwarch: nil, mingw_package_prefix: nil, ruby_bin_dir: nil)
      @msys_path = msys_path
      @msys_path_fixed = msys_path ? true : false
      @mingwdir = nil
      @mingwarch = mingwarch || (
          case RUBY_PLATFORM
            when /x64.*ucrt/ then 'ucrt64'
            when /x64.*mingw32/ then 'mingw64'
            when /i386.*mingw32/ then 'mingw32'
            when /aarch64-mingw-ucrt/ then 'clangarm64'
            else raise "unsupported ruby platform #{RUBY_PLATFORM.inspect}"
          end
        )
      @mingw_package_prefix = mingw_package_prefix || begin
        case @mingwarch
          when 'mingw32' then "mingw-w64-i686"
          when 'mingw64' then "mingw-w64-x86_64"
          when 'ucrt64'  then "mingw-w64-ucrt-x86_64"
          when 'clang64'  then "mingw-w64-clang-x86_64"
          when 'clangarm64' then "mingw-w64-clang-aarch64"
          else raise "unknown mingwarch #{@mingwarch.inspect}"
        end
      end

      @ruby_bin_dir = ruby_bin_dir || File.join(RbConfig::TOPDIR, "bin")
    end

    def reset_cache
      @msys_path = nil unless @msys_path_fixed
    end

    def iterate_msys_paths
      # Prefer MSYS2_PATH if ENV set
      if ENV["MSYS2_PATH"]
        yield ENV["MSYS2_PATH"]
      end
      # Prefer MSYS2 when installed within the ruby directory.
      yield File.join(RbConfig::TOPDIR, "msys64")
      yield File.join(RbConfig::TOPDIR, "msys32")

      # Then try MSYS2 next to the ruby directory.
      yield File.join(File.dirname(RbConfig::TOPDIR), "msys64")
      yield File.join(File.dirname(RbConfig::TOPDIR), "msys32")

      # If msys2 is installed at the default location
      yield "c:/msys64"
      yield "c:/msys32"

      # If msys2 is installed per installer.exe
      require "rubygems"
      require "win32/registry"
      [
        [Win32::Registry::HKEY_CURRENT_USER, MSYS2_INSTALL_KEY],
        [Win32::Registry::HKEY_CURRENT_USER, MSYS2_INSTALL_KEY_WOW],
        [Win32::Registry::HKEY_LOCAL_MACHINE, MSYS2_INSTALL_KEY],
        [Win32::Registry::HKEY_LOCAL_MACHINE, MSYS2_INSTALL_KEY_WOW],
      ].each do |reg_root, base_key|
        begin
          reg_root.open(backslachs(base_key)) do |reg|
            reg.each_key do |subkey|
              subreg = reg.open(subkey)
              begin
                if subreg['DisplayName'] =~ /^MSYS2/ && File.directory?(il=subreg['InstallLocation'])
                  yield il
                end
              rescue Encoding::InvalidByteSequenceError, Win32::Registry::Error
                # Ignore entries without valid installer data or broken character encoding
              end
            end
          rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
            # Avoid crash even if subkey includes inconvertible characters to internal encoding
          end
        rescue Win32::Registry::Error
        end
      end

      ENV['PATH'] && ENV['PATH'].split(";").each do |path|
        # If /path/to/msys64 is in the PATH (e.g. Chocolatey)
        yield path
      end

      # If msys2 is installed by scoop package manager
      begin
        yield IO.popen(["scoop", "prefix", "msys2"], &:read).strip
      rescue SystemCallError
      end

      raise MsysNotFound, "MSYS2 could not be found"
    end

    def msys_path
      @msys_path ||= begin
        iterate_msys_paths do |path|
          if File.exist?(File.join(path, "usr/bin/msys-2.0.dll"))
            break backslachs(path)
          end
        end
      end
    end

    def msys_bin_path
      backslachs( File.join(msys_path, "/usr/bin") )
    end

    def mingw_bin_path
      backslachs( File.join(msys_path, mingwarch, "bin") )
    end

    def mingw_prefix
      "/#{mingwarch}"
    end

    def enable_dll_search_paths
      @mingwdir ||= begin
        DllDirectory.set_defaults
        # Add bundled dll directory for libcrypto.dll loading zlib.dll and legacy.dll loading libcrypto.dll
        DllDirectory.new(RbConfig::CONFIG["rubyarchdir"])
        # Add MSYS2-MINGW DLL directory for user-installed gems
        path = mingw_bin_path
        DllDirectory.new(path) if File.directory?(path)
      rescue MsysNotFound
        # We silently ignore this error to allow Ruby installations without MSYS2.
      end
    end

    def disable_dll_search_paths
      @mingwdir.remove if @mingwdir
      @mingwdir = nil
    end

    private def backslachs(path)
      path.gsub("/", "\\")
    end

    private def msys_apps_envvars
      vars = {}
      msys_bin = msys_bin_path
      mingw_bin = mingw_bin_path
      ruby_bin = backslachs( ruby_bin_dir )
      ridkusepath = ENV["RIDK_USE_PATH"]

      vars['PATH'] = [ridkusepath, ruby_bin, mingw_bin, msys_bin].compact.join(";")
      vars['RI_DEVKIT'] = msys_path
      vars['MSYSTEM'] = mingwarch.upcase
      vars['PKG_CONFIG_PATH'] = "#{mingw_prefix}/lib/pkgconfig:#{mingw_prefix}/share/pkgconfig"
      vars['ACLOCAL_PATH'] = "#{mingw_prefix}/share/aclocal:/usr/share/aclocal"
      vars['MANPATH'] = "#{mingw_prefix}/share/man"
      vars['MINGW_PACKAGE_PREFIX'] = mingw_package_prefix
      if ENV['TMP'] !~ /\A[ -~]*\z/
        # TMP has some Unicode characters -> use MSYS2's /tmp to work around incompat with gcc's temporary files
        vars['TMP'] = backslachs( msys_path + "/tmp" )
      end

      case mingwarch
        when 'mingw32'
          vars['MSYSTEM_PREFIX'] = '/mingw32'
          vars['MSYSTEM_CARCH'] = 'i686'
          vars['MSYSTEM_CHOST'] = 'i686-w64-mingw32'
          vars['MINGW_CHOST'] = vars['MSYSTEM_CHOST']
          vars['MINGW_PREFIX'] = vars['MSYSTEM_PREFIX']
        when 'mingw64'
          vars['MSYSTEM_PREFIX'] = '/mingw64'
          vars['MSYSTEM_CARCH'] = 'x86_64'
          vars['MSYSTEM_CHOST'] = 'x86_64-w64-mingw32'
          vars['MINGW_CHOST'] = vars['MSYSTEM_CHOST']
          vars['MINGW_PREFIX'] = vars['MSYSTEM_PREFIX']
        when 'ucrt64'
          vars['MSYSTEM_PREFIX'] = '/ucrt64'
          vars['MSYSTEM_CARCH'] = 'x86_64'
          vars['MSYSTEM_CHOST'] = 'x86_64-w64-mingw32'
          vars['MINGW_CHOST'] = vars['MSYSTEM_CHOST']
          vars['MINGW_PREFIX'] = vars['MSYSTEM_PREFIX']
        when 'clang64'
          vars['MSYSTEM_PREFIX'] = '/clang64'
          vars['MSYSTEM_CARCH'] = 'x86_64'
          vars['MSYSTEM_CHOST'] = 'x86_64-w64-mingw32'
          vars['MINGW_CHOST'] = vars['MSYSTEM_CHOST']
          vars['MINGW_PREFIX'] = vars['MSYSTEM_PREFIX']
        when 'clangarm64'
          vars['MSYSTEM_PREFIX'] = '/clangarm64'
          vars['MSYSTEM_CARCH'] = 'aarch64'
          vars['MSYSTEM_CHOST'] = 'aarch64-w64-mingw32'
          vars['MINGW_CHOST'] = vars['MSYSTEM_CHOST']
          vars['MINGW_PREFIX'] = vars['MSYSTEM_PREFIX']
        else raise "unknown mingwarch #{@mingwarch.inspect}"
      end

      begin
        locale = IO.popen([File.join(msys_bin, "locale"), "-uU"], &:read)
      rescue SystemCallError
      else
        vars['LANG'] = locale=~/UTF-8/ ? locale.to_s.strip : 'C'
      end

      vars
    end

    private def with_msys_install_hint(if_no_msys = :hint)
      case if_no_msys
      when :hint
        begin
          yield
        rescue MsysNotFound
          enable_colors # force colors, since this message is also shown, when stdout is redirected by "ridk enable"
          $stderr.puts "MSYS2 could not be found. Please run '#{yellow "ridk install"}'"
          $stderr.puts "or download and install MSYS2 manually from https://msys2.org/"
          exit 1
        end
      when :raise
        yield
      else
        raise ArgumentError, "invalid value #{if_no_msys.inspect} for variable if_no_msys"
      end
    end

    def enable_msys_apps(if_no_msys: :hint, for_gem_install: false)
      vars = with_msys_install_hint(if_no_msys) do
        msys_apps_envvars
      end

      changed = false

      if (path=vars.delete("PATH")) && !ENV['PATH'].include?(path)
        phrase = "Temporarily enhancing PATH for MSYS/MINGW..."
        if for_gem_install && defined?(Gem)
          Gem.ui.say(phrase) if Gem.configuration.verbose
        elsif $DEBUG
          $stderr.puts phrase
        end
        changed = true
        ENV['PATH'] = path + ";" + ENV['PATH']
      end
      vars.each do |key, val|
        changed = true if ENV[key] != val
        ENV[key] = val
      end

      changed
    end

    def disable_msys_apps(if_no_msys: :hint)
      vars = with_msys_install_hint(if_no_msys) do
        msys_apps_envvars
      end
      changed = false
      if path=vars.delete("PATH")
        old_path = ENV['PATH']
        ENV['PATH'] = old_path.gsub(path + ";", "")
        changed = ENV['PATH'] != old_path
      end
      vars.each do |key, val|
        changed = true if ENV[key]
        ENV.delete(key)
      end

      changed
    end

    def with_msys_apps_enabled(**args)
      changed = enable_msys_apps(**args)
      begin
        yield
      ensure
        disable_msys_apps(**args) if changed
      end
    end

    def with_msys_apps_disabled(**args)
      changed = disable_msys_apps(**args)
      begin
        yield
      ensure
        enable_msys_apps(**args) if changed
      end
    end

    # This method is used for the ridk command.
    def enable_msys_apps_per_cmd
      vars = with_msys_install_hint{ msys_apps_envvars }
      if (path=vars.delete("PATH")) && !ENV['PATH'].include?(path)
        vars['PATH'] = path + ";" + ENV['PATH']
      end
      vars.map do |key, val|
        "#{key}=#{val}"
      end.join("\n")
    end

    # This method is used for the ridk command.
    def disable_msys_apps_per_cmd
      vars = with_msys_install_hint{ msys_apps_envvars }
      str = "".dup
      if path=vars.delete("PATH")
        str << "PATH=#{ ENV['PATH'].gsub(path + ";", "") }\n"
      end
      str << vars.map do |key, val|
        "#{key}="
      end.join("\n")
    end

    # This method is used for the ridk command.
    def enable_msys_apps_per_ps1
      vars = with_msys_install_hint{ msys_apps_envvars }
      if (path=vars.delete("PATH")) && !ENV['PATH'].include?(path)
        vars['PATH'] = path + ";" + ENV['PATH']
      end
      vars.map do |key, val|
        "$env:#{key}=\"#{val.gsub('"', '`"')}\""
      end.join(";")
    end

    # This method is used for the ridk command.
    def disable_msys_apps_per_ps1
      vars = with_msys_install_hint{ msys_apps_envvars }
      str = "".dup
      if path=vars.delete("PATH")
        str << "$env:PATH=\"#{ ENV['PATH'].gsub(path + ";", "").gsub('"', '`"') }\";"
      end
      str << vars.map do |key, val|
        "$env:#{key}=''"
      end.join(";")
    end

    @@pacman_lock = Mutex.new
    private def with_pacman_lock(&block)
      @@pacman_lock.synchronize(&block)
    end

    def install_packages(packages, verbose: false)
      return if packages.empty?

      with_msys_apps_enabled do
        with_pacman_lock do
          # Find packages that are already installed
          skips, installs = packages.partition do |package|
            IO.popen(["pacman", "-Q", package], err: :out, &:read)
            $?.success?
          end

          Gem.ui.say("Using msys2 packages: #{skips.join(" ")}") if verbose && skips.any?

          # Install required packages
          if installs.any?
            Gem.ui.say("Installing required msys2 packages: #{installs.join(" ")}") if verbose

            args = ["pacman", "-S", "--needed", "--noconfirm", *installs]
            Gem.ui.say("> #{args.join(" ")}") if verbose==1

            res = IO.popen(args, &:read)
            raise CommandError, "pacman failed with the following output:\n#{res}" if !$? || $?.exitstatus != 0

            Gem.ui.say(res) if verbose==1
          end
        end
      end
    end

    def install_mingw_packages(packages, verbose: false)
      packages = packages.map{|pack| "#{mingw_package_prefix}-#{pack}" }
      install_packages(packages, verbose: verbose)
    end
  end
end
end
