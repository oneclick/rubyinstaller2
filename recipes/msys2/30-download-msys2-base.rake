directory File.dirname(self.msys2_base_tar_file)
file self.msys2_base_tar_file => [File.dirname(self.msys2_base_tar_file), :msys2_install_dependencies] do |t|
  sh "wget #{self.msys2_base_tar_url.inspect} -O #{t.name.inspect}"
end
