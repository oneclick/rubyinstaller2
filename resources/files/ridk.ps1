$rubydir = split-path $MyInvocation.MyCommand.Definition -parent

# Execute 'enable' and 'disable' in the context of the current powershell session, so that env vars are effective for subsequent commands.
if ($args[0] -eq "enable" -or $args[0] -eq "disable") {
  $rubyfile = $rubydir + "/ruby"
  $op = $args[0] + "ps1"
  $vars = & $rubyfile --disable-gems -x $MyInvocation.MyCommand.Definition $op @args
  Invoke-Expression $vars
  exit $LastExitCode
}

# Forward 'use' to the script in ridk_use 
if ($args[0] -eq "use") {
  $ridkfile = $rubydir + "/../ridk_use/ridk.ps1"
  . $ridkfile @args
  exit $LastExitCode
}

# Pass all other commands through to ridk.cmd, so that a separate context for env vars is used.
$cmdfile = $rubydir + "/ridk.cmd"
& $cmdfile @args
exit $LastExitCode

#!/mingw64/bin/ruby
require "ruby_installer/runtime"
RubyInstaller::Runtime::Ridk.run!(ARGV)
