require "ruby_installer"

module BuildUtils
  WINDOWS_CMD_SHEBANG = <<-EOT.freeze
  :""||{ ""=> %q<-*- ruby -*-
  @"%~dp0ruby" -x "%~f0" %*
  @exit /b %ERRORLEVEL%
  };{ #
  bindir="${0%/*}" #
  exec "$bindir/ruby" -x "$0" "$@" #
  >, #
  } #
  EOT

  def msys_sh(cmd)
    RubyInstaller.enable_msys_apps
    pwd = Dir.pwd
    sh "sh", "-lc", "cd `cygpath -u #{pwd.inspect}`; #{cmd}"
  end
end
