self.import_files.merge({
  "resources/files/ridk.cmd" => "bin/ridk.cmd",
  "resources/files/ridk.ps1" => "bin/ridk.ps1",
  "resources/files/setrbvars.cmd" => "bin/setrbvars.cmd",
  "resources/files/operating_system.rb" => "lib/ruby/#{package.rubyver2}.0/rubygems/defaults/operating_system.rb",
  "resources/icons/ruby-doc.ico" => "share/doc/ruby/html/images/ruby-doc.ico",
  "resources/ssl/cacert.pem" => "ssl/cert.pem",
  "resources/ssl/README-SSL.md" => "ssl/README-SSL.md",
  "resources/ssl/c_rehash.rb" => "ssl/certs/c_rehash.rb",
  "#{thisdir}/LICENSE.txt" => "LICENSE.txt",
})
