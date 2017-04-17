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

  GEM_ROOT = File.expand_path("../../../..", __FILE__)

  # Return the gemspec of "rubyinstaller-build" which is either already loaded or taken from our root directory.
  def rubyinstaller_build_gemspec
    Gem.loaded_specs["rubyinstaller-build"] or
        Gem::Specification.load(File.join(GEM_ROOT, "rubyinstaller-build.gemspec"))
  end

  # Scan the current and the gem root directory for files matching rel_pattern.
  #
  # All paths returned are relative.
  def ovl_glob(rel_pattern)
    gem_files = Dir.glob(File.join(GEM_ROOT, rel_pattern)).map do |path|
      path.sub(GEM_ROOT+"/", "")
    end

    (gem_files + Dir.glob(rel_pattern)).uniq
  end

  # Returns the absolute path of rel_file within the current directory or,
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

  # Returns the absolute path of rel_file within the gem root directory.
  #
  # Raises Errno::ENOENT if it doesn't exist.
  def gem_expand_file(rel_file)
    if File.exist?(a=File.join(GEM_ROOT, rel_file))
      File.expand_path(a)
    else
      raise Errno::ENOENT, rel_file
    end
  end

  def eval_file(filename)
    code = File.read(filename, encoding: "UTF-8")
    instance_eval(code, filename)
  end


  def ovl_read_file(file_rel)
    File.read(ovl_expand_file(file_rel), encoding: "UTF-8")
  end

  def ovl_compile_erb(erb_file_rel)
    ErbCompiler.new(erb_file_rel).result
  end

  # Quote a string according to the rules of Inno-Setup
  def q_inno(text)
    '"' + text.gsub('"', '""') + '"'
  end
end
end
end
