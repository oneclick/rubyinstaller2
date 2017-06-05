msysdir = File.join(self.sandboxdir, package.msysdir)
directory File.dirname(msysdir)
file msysdir => [msys2_task.devtools, File.dirname(msysdir)] do |t|
  cp_r msys2_task.sandboxdir, t.name

  init_files = File.readlines(msys2_task.after_init_filelist).map(&:chomp) - File.readlines(msys2_task.before_init_filelist).map(&:chomp)

  # Remove files created while MSYS init.
  # These files are re-created on the target computer.
  rm_rf init_files
end
self.sandboxfiles << msysdir
