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
    msys.with_msys_apps_enabled do
      puts "Remove catgets to avoid conflicts while update  ..."
      # See https://github.com/Alexpux/MSYS2-packages/issues/1141
      run_verbose("pacman", "-Rdd", "catgets", "libcatgets", "--noconfirm")

      puts "#{description} part 1  ..."
      # Update the package database and core system packages
      res = run_verbose("pacman", "-Syu", *pacman_args)
      puts "#{description} #{res ? green("succeeded") : red("failed")}"
      raise "pacman failed" unless res

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
