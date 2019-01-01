$rubydir = split-path $MyInvocation.MyCommand.Definition -parent
$rubyfile = $rubydir + "/../bin/ruby"

# Execute 'use' in the context of the current powershell session, so that env vars are effective for subsequent commands.
if ($args[0] -eq "use") {
  $op, $rest = $args
  $op = $op + "ps1"
  $vars = & $rubyfile --disable-gems $rubydir/ridk_use.rb $op $rest
  if ($vars){ Invoke-Expression $vars }
  exit $LastExitCode
}

# Forward any other ridk call to ridk.ps1 of the active ruby version
$rpath = & ruby -rrbconfig -e "puts RbConfig::TOPDIR" $op
$ps1file = $rpath + "/bin/ridk.ps1"
. $ps1file @args
exit $LastExitCode
