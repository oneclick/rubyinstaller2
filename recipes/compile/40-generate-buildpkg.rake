# Erb compile PKGBUILD and write it to the current working directory
self.pkgbuild_compiler = RubyInstaller::Build::ErbCompiler.new(package.pkgbuild)

file pkgbuild_compiler.result_filename => [pkgbuild_compiler.erb_filename_abs] do |t|
  puts "erb #{t.name}"
  pkgbuild_compiler.write_result(self)
end
