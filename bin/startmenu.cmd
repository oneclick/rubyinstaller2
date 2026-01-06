@echo off

set dir=%~dp0
ruby -r "%dir:\=/%../lib/ruby_installer/runtime/console_ui" "%dir:\=/%../resources/files/startmenu.rb"
