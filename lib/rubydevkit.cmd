@for /f "delims=" %%x in ('"%~dp0ruby" -x %~f0 %%*') do set "%%x"
@exit /b %ERRORLEVEL%
#!/mingw64/bin/ruby
#
#   Set MINGW and MSYS2 environment variables
#

require "ruby_installer"

puts RubyInstaller.msys_apps_envvars_for_cmd
