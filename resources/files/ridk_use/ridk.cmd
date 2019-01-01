@echo off

if "x%~1" == "xuse" (
  @echo on
  @for /f "delims=" %%x in ('%~dp0../bin/ruby --disable-gems '%~dp0ridk_use.rb' %*') do @set "%%x"
  @exit /b %ERRORLEVEL%
)

:: Forward any other ridk call to ridk.cmd of the active ruby version
@for /f "delims=" %%x in ('ruby -rrbconfig -e "puts RbConfig::TOPDIR"') do set "RPATH=%%x"
"%RPATH%\bin\ridk.cmd" %*
@exit /b %ERRORLEVEL%
#%/
