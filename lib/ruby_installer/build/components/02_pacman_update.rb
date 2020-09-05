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
      IO.popen(%w[pacman -Q msys2-keyring>=r21], err: :out, &:read)
      if $?.success?
        puts green(" -> up-to-date")
      else
        puts yellow(" -> Update keyring according to https://www.msys2.org/news/#2020-06-29-new-packagers")

        tar_path = download("http://repo.msys2.org/msys/x86_64/msys2-keyring-r21.b39fb11-1-any.pkg.tar.xz")
        sig_path = download("http://repo.msys2.org/msys/x86_64/msys2-keyring-r21.b39fb11-1-any.pkg.tar.xz.sig")
        run_verbose("pacman-key", "--verify", sig_path)
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

      # Update the rest
      puts "#{description} part 2 ..."
      res = run_verbose("pacman", "-Su", *pacman_args)
      puts "#{description} #{res ? green("succeeded") : red("failed")}"
      raise "pacman failed" unless res
    end
  end
end
end
end
end
