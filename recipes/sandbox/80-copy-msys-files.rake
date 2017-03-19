self.sandboxfiles_rel.each do |path|
  destpath = File.join(sandboxdir, path)
  directory File.dirname(destpath)
  unless Rake::Task.task_defined?(destpath)
    file destpath => [File.join(unpackdirmgw, path), File.dirname(destpath)] do |t|
      cp_r(t.prerequisites.first, t.name)
    end
  end
end
