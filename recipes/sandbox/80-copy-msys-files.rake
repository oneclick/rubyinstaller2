self.sandboxfiles.each do |destpath|
  directory File.dirname(destpath)
  unless Rake::Task.task_defined?(destpath)
    file destpath => [destpath.sub(sandboxdir, unpackdirmgw), File.dirname(destpath)] do |t|
      # Copy file like cp_r, but excluding files with task definition
      #   cp_r(t.prerequisites.first, t.name)

      if FileTest.directory?(t.prerequisites.first)
        Dir.glob("**/*", base: t.prerequisites.first, flags: File::FNM_DOTMATCH) do |rel|
          dst = File.join(t.name, rel)
          if Rake::Task.task_defined?(dst)
            # invoke task definition and skip cp
            Rake::Task[dst].invoke
            next
          end
          src = File.join(t.prerequisites.first, rel)
          if FileTest.directory?(src)
            mkdir(dst, verbose: false) unless FileTest.directory?(dst)
          else
            cp(src, dst, verbose: false)
          end
        end
      else
        cp(t.prerequisites.first, t.name)
      end
    end
  end
end
