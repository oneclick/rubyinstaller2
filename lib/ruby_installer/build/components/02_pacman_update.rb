module RubyInstaller
module Build # Use for: Build, Runtime
module Components
class PacmanUpdate < Base
  def self.depends
    %w[msys2]
  end

  def description
    "MSYS2 system update (optional)"
  end

  def execute(args)
    require "tempfile"

    msys.with_msys_apps_enabled do
      puts "Check msys2-keyring version:"
      IO.popen(%w[pacman -Q msys2-keyring>=1~20210213-2], err: :out, &:read)
      if $?.success?
        puts green(" -> up-to-date")
      else
        puts yellow(" -> Update keyring according to https://www.msys2.org/news/#2020-06-29-new-packagers")

        tar_path = File.join(builtin_packages_dir, "msys2-keyring-1~20210213-2-any.pkg.tar.zst")
        tf = Tempfile.new
        run_verbose("pacman", "-U", "--noconfirm", "--config", tf.path, tar_path)
      end

      puts "Remove catgets to avoid conflicts while update  ..."
      # See https://github.com/Alexpux/MSYS2-packages/issues/1141
      run_verbose("pacman", "-Rdd", "catgets", "libcatgets", "--noconfirm")

      puts "#{description} part 1  ..."
      # Update the package database and core system packages
      res = run_verbose("pacman", "-Syu", *pacman_args)
      puts "#{description} #{res ? green("succeeded") : red("failed")}"
      raise "pacman failed" unless res

      kill_all_msys2_processes
      autorebase

      # Update the rest
      puts "#{description} part 2 ..."
      res = run_verbose("pacman", "-Syu", *pacman_args)
      puts "#{description} #{res ? green("succeeded") : red("failed")}"
      raise "pacman failed" unless res

      autorebase
    end
  end
end
end
end
end
