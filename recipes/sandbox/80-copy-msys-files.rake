self.sandboxfiles.each do |destpath|
  directory File.dirname(destpath)
  unless Rake::Task.task_defined?(destpath)
    file destpath => [destpath.sub(sandboxdir, unpackdirmgw), File.dirname(destpath)] do |t|
      if File.file?(t.prerequisites.first)
        cp(t.prerequisites.first, t.name)
      elsif File.directory?(t.prerequisites.first) && !File.exist?(t.name)
        mkdir t.name
      end
    end
  end
end
