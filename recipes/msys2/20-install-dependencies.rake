task :msys2_install_dependencies do
  msys_sh <<-EOT
    pacman -S --needed --noconfirm  tar wget findutils
  EOT
end
