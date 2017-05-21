untardir = File.dirname(self.sandboxdir)
directory untardir
file self.sandboxdir => [self.msys2_base_tar_file, untardir] do |t|
  sh "tar xf #{self.msys2_base_tar_file.inspect} -C #{untardir.inspect}"
  touch self.sandboxdir
end
