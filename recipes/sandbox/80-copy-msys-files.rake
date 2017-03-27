self.sandboxfiles.each do |destpath|
  directory File.dirname(destpath)
  unless Rake::Task.task_defined?(destpath)
    file destpath => [destpath.sub(sandboxdir, unpackdirmgw), File.dirname(destpath)] do |t|
      cp_r(t.prerequisites.first, t.name)
    end
  end
end
