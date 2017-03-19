file archivefile => sandbox_task.sandboxfiles do
  rm_f archivefile
  msys_sh <<-EOT
    pacman -S --needed --noconfirm p7zip
  EOT

  chdir "recipes/sandbox" do
    sh "sh 7z a -bd ../../#{archivefile} #{sandboxdir.sub("recipes/sandbox/", "")} | ruby -ne \"STDERR.print '.'\""
  end
end
