directory File.dirname(self.msys2_base_tar_file)
file self.msys2_base_tar_file => File.dirname(self.msys2_base_tar_file) do |t|
  sh "curl #{self.msys2_base_tar_url.inspect} -o #{t.name.inspect}"
end
