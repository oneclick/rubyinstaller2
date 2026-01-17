require "ruby_installer/runtime"

app = RubyInstaller::Runtime::ConsoleUi.new
bm = RubyInstaller::Runtime::ConsoleUi::ButtonMatrix.new ncols: 3
bm.headline = "Ruby startmenu  -  Choose item by mouse or cursor keys and press Enter"

bt = <<~EOT
  irb:>

  Interactive
  Ruby
EOT
bm.add_button bt do
  app.clear_screen
  RubyInstaller::Runtime::Ridk.print_logo
  puts "\nStarting irb. To show the irb command help, type `help` and press Enter."
  Kernel.system File.join(RbConfig::CONFIG["bindir"], "irb.bat")
end

html_path = File.join(RbConfig::CONFIG["prefix"], "share/doc/ruby/html/index.html")
if File.exist?(html_path)
  bt = <<~EOT
    Core and
    stdlib
    API
  EOT
  bm.add_button bt do
    puts "\nStarting browser at #{html_path}"
    Kernel.exec "cmd", "/c", "start", html_path
  end
end

bt = <<~EOT
  gem doc
  server

  view docs of
  installed gems
EOT
bm.add_button bt do
  app.clear_screen
  puts "\nShow documentation of local installed gems"
  gem = File.join(RbConfig::CONFIG["bindir"], "gem")
  system gem, "install", "--conservative", "webrick", "rubygems-server"
  system gem, "server", "--launch"
end

bt = <<~EOT
  C:>

  ruby enabled
  command line
EOT
bm.add_button bt do
  app.clear_screen
  puts "\nRun cmd.exe with ruby environment variables (ridk enable)\n\n"
  ridk = File.join(RbConfig::CONFIG["bindir"], "ridk")
  Kernel.system "cmd", "/E:ON", "/K", ridk, "enable"
end

bt = <<~EOT
  Install
  MSYS2-Devkit

  necessary for
  many gems
EOT
bm.add_button bt do
  puts "\nInstall MSYS2-Devkit (ridk install)"
  ridk = File.join(RbConfig::CONFIG["bindir"], "ridk")
  Kernel.system ridk, "install"
end

app.widget = bm
app.run!


# The icons that were installed before ruby-4.0:
#
# Name: {autoprograms}\{#InstallerName}\{cm:InteractiveRubyTitle}; Filename: {app}\bin\irb.<%= package.rubyver2 < '3.1' ? "cmd" : "bat" %>; IconFilename: {app}\bin\ruby.exe
#
# Name: {autoprograms}\{#InstallerName}\{cm:DocumentationTitle}\{cm:APIReferenceTitle,{#RubyVersion}}; Filename: {app}\share\doc\ruby\html\index.html; IconFilename: {app}\share\doc\ruby\html\images\ruby-doc.ico; Components: rdoc
#
# Name: {autoprograms}\{#InstallerName}\{cm:RubyGemsDocumentationServerTitle}; Filename: {app}\bin\gem.cmd; Parameters: install --conservative webrick rubygems-server & {app}\bin\gem.cmd server --launch; IconFilename: {app}\share\doc\ruby\html\images\ruby-doc.ico; Flags: runminimized
#
# Name: {autoprograms}\{#InstallerName}\{cm:StartCmdPromptWithRubyTitle}; Filename: {sys}\cmd.exe; Parameters: /E:ON /K {app}\bin\ridk enable; WorkingDir: {%HOMEDRIVE}{%HOMEPATH}; IconFilename: {sys}\cmd.exe
#
# Name: {autoprograms}\{#InstallerName}\{cm:UninstallProgram,{#InstallerName}}; Filename: {uninstallexe}
