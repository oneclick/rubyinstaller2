@echo off

if "x%~1" == "xenable" (
  goto :setvars
)
if "x%~1" == "xdisable" (
  goto :setvars
)
if "x%~1" == "xexec" (
  goto :exec
)
if "x%~1" == "xuse" (
  goto :use
)

"%~dp0ruby" -x "%~f0" %*
@exit /b %ERRORLEVEL%

:exec
rem pass the command to a bash shell
setlocal
for /f "delims=" %%x in ('"%~dp0ruby" --disable-gems -x '%~f0' %1') do set "%%x"
shift
shift
%0 %1 %2 %3 %4 %5 %6 %7 %8 %9
@exit /b %ERRORLEVEL%

:setvars
@echo on
@for /f "delims=" %%x in ('"%~dp0ruby" --disable-gems -x '%~f0' %*') do set "%%x"
@exit /b %ERRORLEVEL%

:use
"%~dp0../ridk_use/ridk.cmd" %*
@exit /b %ERRORLEVEL%

#!/mingw64/bin/ruby
require "ruby_installer/runtime"
RubyInstaller::Runtime::Ridk.run!(ARGV)
