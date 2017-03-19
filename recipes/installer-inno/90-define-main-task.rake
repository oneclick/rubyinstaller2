desc "installer for ruby-#{package.rubyver}-#{package.arch}"
task "installer-inno" => ["sandbox", installer_exe]
