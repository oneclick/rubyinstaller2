desc "7z archive for ruby-#{package.rubyver}-#{package.arch}"
task "archive-7z" => ["sandbox", archivefile]
