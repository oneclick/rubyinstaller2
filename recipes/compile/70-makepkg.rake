# Build ruby pkg.tar.xz file
directory package.compiledir
file pkgfile => [pkgbuild_compiler.result_filename, package.compiledir, *source_files] do
  chdir(package.compiledir) do
    msys_sh "MINGW_INSTALLS=#{package.mingwdir} makepkg-mingw -sf --noconfirm"
  end
end
