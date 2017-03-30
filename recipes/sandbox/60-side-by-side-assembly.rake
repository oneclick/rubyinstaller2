libruby_regex = /msvcrt-ruby\d+\.dll$/i
bin_dir = File.join(sandboxdir, "bin")
dlls_dir = File.join(sandboxdir, "bin/ruby_builtin_dlls")
directory bin_dir
directory dlls_dir

dlls = self.sandboxfiles.select do |destpath|
  destpath.start_with?(bin_dir+"/") && destpath =~ /\.dll$/i && destpath !~ libruby_regex
end

dlls.each do |destpath|
  new_destpath = File.join(File.dirname(destpath), "ruby_builtin_dlls", File.basename(destpath))
  file new_destpath => [destpath.sub(sandboxdir, unpackdirmgw), dlls_dir] do |t|
    cp(t.prerequisites.first, t.name)
  end

  # move the DLL file in the list of sandboxed files as well
  self.sandboxfiles.delete(destpath)
  self.sandboxfiles << new_destpath
end

self.sandboxfiles.select do |destpath|
  destpath =~ /\/rubyw?\.exe$/i
end.each do |destpath|
  file destpath => [destpath.sub(sandboxdir, unpackdirmgw), bin_dir] do |t|
    puts "patching manifest of #{t.name}"
    libruby = File.basename(self.sandboxfiles.find{|a| a=~libruby_regex })

    image = File.binread(t.prerequisites.first)
    new = <<-EOT
      <dependency>
        <dependentAssembly>
          <assemblyIdentity version="1.0.0.0" type="win32" name="ruby_builtin_dlls" />
        </dependentAssembly>
      </dependency>
      <file name="#{ libruby }"/>
    EOT

    # Microsofts "mt.exe" can add a manifest to a given exe file, but since we use mingw only, we patch the exe file manually.
    # MINGW requires to specify a the manifest while linking, but this would require additional patching of the ruby build process.
    image.gsub!(/<\?xml.*?<assembly.*?<\/assembly>\n/m) do |m|
      newm = m.gsub(/^\s*<\/assembly>\s*$/, new + "</assembly>")
        .gsub(/<!--.*?-->/m, "")
        .gsub(/^ +/, "")
        .gsub(/\n+/m, "\n")

      raise "replacement manifest to big #{m.bytesize} < #{newm.bytesize}" if m.bytesize < newm.bytesize
      newm + " " * (m.bytesize - newm.bytesize)
    end
    File.binwrite(t.name, image)
  end
end

manifest2 = File.join(sandboxdir, "bin/ruby_builtin_dlls/ruby_builtin_dlls.manifest")
file manifest2 => [dlls_dir] do |t|
  puts "generate #{t.name}"
  File.binwrite t.name, <<-EOT
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
      <assemblyIdentity type="win32" name="ruby_builtin_dlls" version="1.0.0.0"></assemblyIdentity>

      #{ dlls.map{|dll| %Q{<file name="#{File.basename(dll)}"/>} }.join }
    </assembly>
  EOT
end
self.sandboxfiles << manifest2
