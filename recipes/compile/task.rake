class CompileTask < RubyInstaller::Build::BaseTask
  def initialize(*args)
    super
    self.pkgfile = File.join(package.compiledir, "#{package.pacman_arch}-ruby-#{package.rubyver_pkgrel}-any.pkg.tar.xz")

    desc "pacman package for ruby-#{package.rubyver}-#{package.arch}"
    task "compile" => [pkgfile]

    # Erb compile PKGBUILD and write it to the current working directory
    pkgbuild_compiler = RubyInstaller::Build::ErbCompiler.new(package.pkgbuild)
    file pkgbuild_compiler.result_filename => [pkgbuild_compiler.erb_filename_abs] do |t|
      puts "erb #{t.name}"
      pkgbuild_compiler.write_result
    end

    # Copy other source files to the current working directory
    source_files = File.read(pkgbuild_compiler.erb_filename_abs, encoding: 'utf-8')
        .match(/source=\((.*?)\)/m)[1].split
        .reject{|f| f=~/https?:\/\// }
        .map{|f| File.join(package.compiledir, f) }
    source_files.each do |f|
      file f => gem_expand_file(f) do |t|
        cp t.prerequisites.first, f
      end
    end

    # Build ruby pkg.tar.xz file
    directory package.compiledir
    file pkgfile => [pkgbuild_compiler.result_filename, package.compiledir, *source_files] do
      chdir(package.compiledir) do
        msys_sh "MINGW_INSTALLS=#{package.mingwdir} makepkg-mingw -sf --noconfirm"
      end
    end
  end
end
