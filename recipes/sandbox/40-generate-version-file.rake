versionfile = File.join(sandboxdir, "lib/ruby/site_ruby/2.4.0/ruby_installer/runtime/package_version.rb")
directory File.dirname(versionfile)
file versionfile => [File.dirname(versionfile), ovl_expand_file(package.pkgbuild),
                      File.exist?('.git/logs/HEAD') && '.git/logs/HEAD'].select{|a|a} do |t|
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
