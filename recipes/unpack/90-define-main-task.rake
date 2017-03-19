desc "unpack ruby-#{package.rubyver} and dependend packages"
task "unpack" => ["compile", ruby_exe]
