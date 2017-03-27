# Create a version file for the rubyinstaller runtime

versionfile_rel = "lib/ruby/site_ruby/#{package.rubyver2}.0/ruby_installer/runtime/package_version.rb"
versionfile = File.join(sandboxdir, versionfile_rel)
directory File.dirname(versionfile)
file versionfile => [ File.dirname(versionfile),
                      File.exist?('.git/logs/HEAD') && '.git/logs/HEAD',
                    ].select{|a|a} do |t|
  puts "generate #{t.name}"
  File.binwrite t.name, <<-EOT
module RubyInstaller
module Runtime
PACKAGE_VERSION = #{package.rubyver_pkgrel.inspect}
GIT_COMMIT = #{`git rev-parse HEAD`.chomp[0, 7].inspect}
end
end
  EOT
end

self.sandboxfiles << versionfile
