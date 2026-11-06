file self.after_init_filelist => [self.before_init_filelist] do |t|
  chdir self.sandboxdir do
    # initialize MSYS2
    RubyInstaller::Build.msys2_installation.with_msys_apps_disabled do
      sh "autorebase.bat" if sandboxdir=~/\/msys32$/
      # Unset HOME, which is set by ruby.exe to HOMEDRIVE+HOMEPATH but MSYS2 has it's own HOME.
      # The HOME must be missing initially to trigger MSYS2 initialization.
      # POSIXLY_CORRECT is set in GHA and also blocks MSYS2 initialization.
      sh({ "HOME" => nil, "POSIXLY_CORRECT" => nil }, "usr/bin/sh", "-lc", "true")
    end

    sh "find > #{File.basename self.after_init_filelist}"
  end
end
