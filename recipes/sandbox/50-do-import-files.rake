import_files.each do |source, dest|
  file File.join(sandboxdir, dest) => ovl_expand_file(source) do |t|
    mkdir_p File.dirname(t.name)
    content = File.binread(t.prerequisites.first)
    # Rewrite certain files from RubyInstaller::Build to RubyInstaller::Runtime.
    rewrite_done = false
    content.gsub!(REWRITE_MARK) do
      rewrite_done = true
      "module Runtime # Rewrite from #{t.prerequisites.first}"
    end
    File.binwrite(t.name, content)
    puts "import#{" with rewrite" if rewrite_done} #{t.prerequisites.first} #{t.name}"
  end
end
