module RubyInstaller
  # :nodoc:
  module Ridk
    class << self
      include RubyInstaller::Colors

      def run!(args)
        enable_colors
        case args[0]
          when 'install'
            install(args[1..-1])
          when 'enable', 'exec'
            puts RubyInstaller.msys2_installation.enable_msys_apps_per_cmd
          when 'disable'
            puts RubyInstaller.msys2_installation.disable_msys_apps_per_cmd
          when 'enableps1', 'execps1'
            puts RubyInstaller.msys2_installation.enable_msys_apps_per_ps1
          when 'disableps1'
            puts RubyInstaller.msys2_installation.disable_msys_apps_per_ps1
          when 'version'
            print_version
          when 'help', '--help', '-?', '/?', nil
            print_help
          else
            $stderr.puts "Invalid option #{args[0].inspect}"
        end
      end

      def msys_version_info(msys_path)
        require "rexml/document"
        doc = File.open( File.join(msys_path, "components.xml") ) do |fd|
          REXML::Document.new fd
        end
        {
          "title" => doc.elements.to_a("//Packages/Package/Title").first.text,
          "version" => doc.elements.to_a("//Packages/Package/Version").first.text,
        }
      end

      def ignore_err
        begin
          yield
        rescue
        end
      end

      def print_version
        require "yaml"
        require "rbconfig"

        h = {
          "ruby" => { "version" => RUBY_VERSION,
                      "platform" => RUBY_PLATFORM },
          "ruby_installer" => { "version" => RubyInstaller::VERSION,
                                "git_commit" => RubyInstaller::GIT_COMMIT },
        }

        ignore_err do
          msys = RubyInstaller.msys2_installation
          msys.enable_msys_apps(if_no_msys: :raise)

          msys_ver = ignore_err{ msys_version_info(msys.msys_path) }
          h["msys2"] = { "path" => msys.msys_path }.merge(msys_ver || {})
        end

        ignore_err do
          cc = RbConfig::CONFIG['CC']
          ver, _ = `#{cc} --version`.split("\n", 2)
          h["cc"] = ver
        end

        ignore_err do
          ver, _ = `sh --version`.split("\n", 2)
          h["sh"] = ver
        end

        puts h.to_yaml
      end

      def print_help
        $stdout.puts <<-EOT
Usage:
    #{$0} [option]

Option:
    install                   Install MSYS2 and MINGW dev tools
    exec <command>            Execute a command within MSYS2 context
    enable                    Set environment variables for MSYS2
    disable                   Unset environment variables for MSYS2
    version                   Print RubyInstaller and MSYS2 versions
    help | --help | -? | /?   Display this help and exit
EOT
      end
    end
  end
end
