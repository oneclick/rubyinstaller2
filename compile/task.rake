require "ostruct"
require "rake"
require "build_utils"

class CompileTask < OpenStruct
  include Rake::DSL
  include BuildUtils

  def initialize(*args)
    super
    self.pkgfile = File.join(package.compiledir, "mingw-w64-x86_64-ruby-#{package.rubyver_pkgrel}-any.pkg.tar.xz")

    desc "Build pacman package for ruby-#{package.rubyver}"
    task "compile" => [:devkit, pkgfile]

    self.readline_pkgfile = File.join("compile", "mingw-w64-readline", "mingw-w64-x86_64-readline-6.3.008-1-any.pkg.tar.xz")
    file readline_pkgfile => [package.pkgbuild] do |t|
      chdir(File.dirname(t.name)) do
        pkgfile = File.basename(readline_pkgfile)
        msys_sh "MINGW_INSTALLS=mingw64 makepkg-mingw -sf &&
        (pacman --noconfirm -U #{pkgfile.inspect} || rm -f #{pkgfile.inspect})"
      end
    end

    file pkgfile => [package.pkgbuild, readline_pkgfile] do
      chdir(package.compiledir) do
        cp Dir[File.join(rootdir, "resources/icons/*.ico")], "."
        msys_sh "MINGW_INSTALLS=mingw64 makepkg-mingw -sf"
      end
    end
  end
end
