# Move bundled RubyInstaller DLLs to a subdirectory.
# This avoids interferences with other apps when ruby.exe is in the PATH.

libruby_regex = /(msvcrt|ucrt)-ruby\d+\.dll$/i
bin_dir = File.join(sandboxdir, "bin")
dlls_dir = File.join(sandboxdir, "bin/ruby_builtin_dlls")
directory bin_dir
directory dlls_dir

# Select the DLLs from "bin/" which shall be moved into "bin/ruby_builtin_dlls/"
dlls = self.sandboxfiles.select do |destpath|
  destpath.start_with?(bin_dir+"/") && destpath =~ /\.dll$/i && destpath !~ libruby_regex
end

dlls.each do |destpath|
  # Add tasks to write the DLLs into the sub directory
  new_destpath = File.join(File.dirname(destpath), "ruby_builtin_dlls", File.basename(destpath))
  file new_destpath => [destpath.sub(sandboxdir, unpackdirmgw), dlls_dir] do |t|
    cp(t.prerequisites.first, t.name)
  end

  # Move the DLLs in the dependent files list to the subdirectory
  self.sandboxfiles.delete(destpath)
  self.sandboxfiles << new_destpath
end

# Add a custom manifest to both ruby.exe and rubyw.exe, so that they find the DLLs to be moved
self.sandboxfiles.select do |destpath|
  destpath =~ /\/rubyw?\.exe$/i
end.each do |destpath|
  file destpath => [destpath.sub(sandboxdir, unpackdirmgw), bin_dir] do |t|
    puts "patching manifest of #{t.name}"
    libruby = File.basename(self.sandboxfiles.find{|a| a=~libruby_regex })

    image = File.binread(t.prerequisites.first)
    # The XML elements we want to add to the default MINGW manifest:
    new = <<-EOT
      <application xmlns="urn:schemas-microsoft-com:asm.v3">
        <windowsSettings xmlns:ws2="http://schemas.microsoft.com/SMI/2016/WindowsSettings">
          <ws2:longPathAware>true</ws2:longPathAware>
        </windowsSettings>
      </application>
      <dependency>
        <dependentAssembly>
          <assemblyIdentity version="1.0.0.0" type="win32" name="ruby_builtin_dlls" />
        </dependentAssembly>
      </dependency>
      <file name="#{ libruby }"/>
    EOT

    # There are two regular options to add a custom manifest:
    # 1. Change a given exe file per Microsofts "mt.exe" after the build
    # 2. Specify a the manifest while linking with the MINGW toolchain
    #
    # Since we don't want to depend on particular Microsoft tools and want to avoid additional patching of the ruby build, we do a nifty trick here.
    # We patch the exe file manually.
    # Removing unnecessary spaces and comments from the embedded XML manifest gives us enough space to add the above XML elements.
    # Then the default MINGW manifest gets replaced by our custom XML content.
    # The rest of the available bytes is simply padded with spaces, so that we don't change positions within the EXE image.
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

# Add a detached manifest file within the sub directory that lists all DLLs in question
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
