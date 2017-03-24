# Build ruby pkg.tar.xz file
directory compiledir
file pkgfile => [pkgbuild_compiler.result_filename, compiledir, *source_files] do
  chdir(compiledir) do
    msys_sh "MINGW_INSTALLS=#{package.mingwdir} makepkg-mingw -sf --noconfirm"
  end
end
