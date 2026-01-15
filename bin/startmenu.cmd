@echo off

REM This is sufficient to load console_ui.rb, but files located in
REM lib/ruby_installer/build cannot be loaded; instead, they are used
REM from the libraries installed with the ruby executable.
REM ie, ruby_installer/runtime/colors.rb is loaded from ruby installation.

set dir=%~dp0
ruby -I "%dir:\=/%../lib" "%dir:\=/%../resources/files/startmenu.rb"
