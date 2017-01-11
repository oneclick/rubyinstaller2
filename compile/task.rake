require "base_task"

class CompileTask < BaseTask
  def initialize(*args)
    super
    self.pkgfile = File.join(package.compiledir, "#{package.pacman_arch}-ruby-#{package.rubyver_pkgrel}-any.pkg.tar.xz")

    desc "Build pacman package for ruby-#{package.rubyver}-#{package.arch}"
    task "compile" => [:devkit, pkgfile]

    self.readline_pkgfile = File.join("compile", "mingw-w64-readline", "#{package.pacman_arch}-readline-6.3.008-1-any.pkg.tar.xz")
    file readline_pkgfile => [package.pkgbuild] do |t|
      chdir(File.dirname(t.name)) do
        pkgfile = File.basename(readline_pkgfile)
        msys_sh "MINGW_INSTALLS=#{package.mingwdir} makepkg-mingw -sf &&
        (pacman --noconfirm -U #{pkgfile.inspect} || rm -f #{pkgfile.inspect})"
      end
    end

    file pkgfile => [package.pkgbuild, readline_pkgfile] do
      chdir(package.compiledir) do
        cp Dir[File.join(package.rootdir, "resources/icons/*.ico")], "."
        msys_sh "MINGW_INSTALLS=#{package.mingwdir} makepkg-mingw -sf"
      end
    end
  end
end
