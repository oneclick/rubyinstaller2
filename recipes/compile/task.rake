class CompileTask < RubyInstaller::Build::BaseTask
  def initialize(*args)
    super
    self.pkgfile = File.join(package.compiledir, "#{package.pacman_arch}-ruby-#{package.rubyver_pkgrel}-any.pkg.tar.xz")

    desc "pacman package for ruby-#{package.rubyver}-#{package.arch}"
    task "compile" => [pkgfile]

    directory package.compiledir
    file pkgfile => [ovl_expand_file(package.pkgbuild), package.compiledir] do
      chdir(package.compiledir) do
        files = ovl_glob(File.join(package.rootdir, "resources/icons/*.ico"))
        absfiles = files.map{|f| ovl_expand_file(f) }
        cp absfiles, "."
        msys_sh "MINGW_INSTALLS=#{package.mingwdir} makepkg-mingw -sf --noconfirm"
      end
    end
  end
end
