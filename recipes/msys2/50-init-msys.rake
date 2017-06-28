file self.after_init_filelist => [self.before_init_filelist] do |t|
  chdir self.sandboxdir do
    # initialize MSYS2
    sh "usr/bin/sh", "-lc", "true"

    sh "find -type f > #{File.basename self.after_init_filelist}"
  end
end
