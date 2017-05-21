msysdir = File.join(self.sandboxdir, package.msysdir)
directory File.dirname(msysdir)
file msysdir => [msys2_task.devtools, File.dirname(msysdir)] do |t|
  cp_r msys2_task.sandboxdir, t.name
end
self.sandboxfiles << msysdir
