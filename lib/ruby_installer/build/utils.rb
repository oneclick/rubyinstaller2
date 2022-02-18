module RubyInstaller
module Build
module Utils
  WINDOWS_CMD_SHEBANG = <<-EOT.freeze
:""||{ ""=> %q<-*- ruby -*-
@"%~dp0ruby" -x "%~f0" %*
@exit /b %ERRORLEVEL%
};{ #
bindir="${0%/*}" #
exec "$bindir/ruby" -x "$0" "$@" #
>, #
} #
EOT

  def msys_sh(cmd)
    Build.enable_msys_apps
    pwd = Dir.pwd
    sh "sh", "-lc", "cd `cygpath -u #{pwd.inspect}`; #{cmd}"
  end

  def with_env(hash)
    olds = hash.map{|k, _| [k, ENV[k.to_s]] }
    hash.each do |k, v|
      ENV[k.to_s] = v
    end
    begin
      yield
    ensure
      olds.each do |k, v|
        ENV[k.to_s] = v
      end
    end
  end

  def with_sandbox_ruby
    path = "#{ File.expand_path(File.join(sandboxdir, "bin")) };#{ ENV["PATH"] }"
    with_env(GEM_HOME: nil, GEM_PATH: nil, RUBYOPT: nil, RUBYLIB: nil, PATH: path) do
      yield
    end
  end

  GEM_ROOT = File.expand_path("../../../..", __FILE__)

  # Return the gem files of "rubyinstaller-build"
  #
  # The gemspec is either already loaded or taken from our root directory.
  def rubyinstaller_build_gem_files
    spec = Gem.loaded_specs["rubyinstaller-build"]
    if spec
      # A loaded gemspec has empty #files -> fetch the files from its path.
      # This is preferred to gemspec loading to avoid a dependency to git.
      Dir["**/*", base: spec.full_gem_path].select do |f|
        FileTest.file?(File.join(spec.full_gem_path, f))
      end
    else
      # Not yet loaded -> load the gemspec and return the files added to the gemspec.
      Gem::Specification.load(File.join(GEM_ROOT, "rubyinstaller-build.gemspec")).files
    end
  end

  # Scan the current and the gem root directory for files matching +rel_pattern+.
  #
  # All paths returned are relative.
  def ovl_glob(rel_pattern)
    gem_files = Dir.glob(File.join(GEM_ROOT, rel_pattern)).map do |path|
      path.sub(GEM_ROOT+"/", "")
    end

    (gem_files + Dir.glob(rel_pattern)).uniq
  end

  # Returns the absolute path of +rel_file+ within the current directory or,
  # if it doesn't exist, from the gem root directory.
  #
  # Raises Errno::ENOENT if neither of them exist.
  def ovl_expand_file(rel_file)
    if File.exist?(rel_file)
      File.expand_path(rel_file)
    elsif File.exist?(a=File.join(GEM_ROOT, rel_file))
      File.expand_path(a)
    else
      raise Errno::ENOENT, rel_file
    end
  end

  def eval_file(filename)
    code = File.read(filename, encoding: "UTF-8")
    instance_eval(code, filename)
  end

  # Read +rel_file+ from the current directory or, if it doesn't exist, from the gem root directory.
  # Raises Errno::ENOENT if neither of them exist.
  #
  # Returns the file content as String with UTF-8 encoding.
  def ovl_read_file(rel_file)
    File.read(ovl_expand_file(rel_file), encoding: "UTF-8")
  end

  # Quote a string according to the rules of Inno-Setup
  def q_inno(text)
    '"' + text.to_s.gsub('"', '""') + '"'
  end

  # Extend rake's file task to be defined only once and to check the expected file is indeed generated
  #
  # The same as #task, but for #file.
  # In addition this file task raises an error, if the file that is expected to be generated is not present after the block was executed.
  def file(name, *args, &block)
    task_once(name, block) do
      super(name, *args) do |ta|
        block.call(ta).tap do
          raise "file #{ta.name} is missing after task executed" unless File.exist?(ta.name)
        end
      end
    end
  end

  # Extend rake's task definition to be defined only once, even if called several times
  #
  # This allows to define common tasks next to specific tasks.
  # It is expected that any variation of the task's block is reflected in the task name or namespace.
  # If the task name is identical, the task block is executed only once, even if the file task definition is executed twice.
  def task(name, *args, &block)
    task_once(name, block) do
      super
    end
  end

  private def task_once(name, block)
    name = name.keys.first if name.is_a?(Hash)
    if block &&
        Rake::Task.task_defined?(name) &&
        Rake::Task[name].instance_variable_get('@task_block_location') == block.source_location
      # task is already defined for this target and the same block
      # So skip double definition of the same action
      Rake::Task[name]
    elsif block
      yield.tap do
        Rake::Task[name].instance_variable_set('@task_block_location', block.source_location)
      end
    else
      yield
    end
  end

end
end
end
