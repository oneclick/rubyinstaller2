file self.after_init_filelist => [self.before_init_filelist] do |t|
  chdir self.sandboxdir do
    # initialize MSYS2
    RubyInstaller::Build.msys2_installation.with_msys_apps_disabled do
      sh "autorebase.bat" if sandboxdir=~/\/msys32$/
      sh "usr/bin/sh", "-lc", "true"
    end

    sh "find > #{File.basename self.after_init_filelist}"
  end
end
