untardir = File.dirname(self.sandboxdir)
directory untardir
file self.before_init_filelist => [self.msys2_base_tar_file, untardir] do |t|
  sh "tar xf #{self.msys2_base_tar_file.inspect} -C #{untardir.inspect}"

  chdir self.sandboxdir do
    sh "find > #{File.basename self.before_init_filelist}"
  end
end
