class CompileTask < RubyInstaller::Build::BaseTask
  def initialize(*args)
    super
    self.pkgfile = File.join(package.compiledir, "#{package.pacman_arch}-ruby-#{package.rubyver_pkgrel}-any.pkg.tar.xz")

    desc "pacman package for ruby-#{package.rubyver}-#{package.arch}"
    task "compile" => [:devkit, pkgfile]

    file pkgfile => [package.pkgbuild] do
      chdir(package.compiledir) do
        cp Dir[File.join(package.rootdir, "resources/icons/*.ico")], "."
        msys_sh "MINGW_INSTALLS=#{package.mingwdir} makepkg-mingw -sf --noconfirm"
      end
    end
  end
end
