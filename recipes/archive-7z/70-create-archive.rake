file archivefile => sandbox_task.sandboxfiles do
  rm_f archivefile
  msys_sh <<-EOT
    pacman -S --needed --noconfirm $MINGW_PACKAGE_PREFIX-7zip
  EOT

  chdir "recipes/sandbox" do
    sh "7z a -bd -snl ../../#{archivefile} #{sandboxdir.sub("recipes/sandbox/", "")} | ruby -ne \"STDERR.print '.'\""
  end
end
