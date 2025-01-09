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

ext_dll_defs = {
  "lib/ruby/#{package.rubylibver}/#{package.ruby_arch}/fiddle.so" => /^libffi-\d.dll$/,
  "lib/ruby/#{package.rubylibver}/#{package.ruby_arch}/openssl.so" => /^libssl-[\d_]+(-x64)?.dll$|^libcrypto-[\d_]+(-x64)?.dll$/,
  "lib/ruby/#{package.rubylibver}/#{package.ruby_arch}/psych.so" => /^libyaml-[-\d]+.dll$/,
  "lib/ruby/#{package.rubylibver}/#{package.ruby_arch}/zlib.so" => /^zlib\d.dll$/,
}

core_dll_defs = [
  /^libgmp-\d+.dll$/,
  /^libwinpthread-\d+.dll$/,
  /^libgcc_s_.*.dll$/,
]

# create rake tasks to trigger additional processing of so files
ext_dll_defs.keys.each do |so_file|
  self.sandboxfiles << File.join(sandboxdir, so_file)
end

core_dlls, dlls = dlls.partition do |destpath|
  core_dll_defs.any? { |re| re =~ File.basename(destpath) }
end
ext_dlls, dlls = dlls.partition do |destpath|
  ext_dll_defs.values.any? { |re| re =~ File.basename(destpath) }
end
raise "DLL belonging neither to core nor to exts: #{dlls}" unless dlls.empty?


###########################################################################
# Add manifest to extension.so files pointing to linked MINGW library DLLs
# next to it
###########################################################################

# Add tasks to move the DLLs into the extension directory
ext_dlls.each do |destpath|
  so_fname, _ = ext_dll_defs.find { |_, re| re =~ File.basename(destpath) }

  new_destpath = File.join(sandboxdir, File.dirname(so_fname), File.basename(destpath))
  file new_destpath => [destpath.sub(sandboxdir, unpackdirmgw), File.dirname(new_destpath)] do |t|
    cp(t.prerequisites.first, t.name)
  end

  # Move the DLLs in the dependent files list to the subdirectory
  self.sandboxfiles.delete(destpath)
  self.sandboxfiles << new_destpath
end

# Add a custom manifest to each extension.so, so that they find the DLLs to be moved
ext_dlls.each do |destpath|
  so_fname, _ = ext_dll_defs.find { |_, re| re =~ File.basename(destpath) }
  sandbox_so_fname = File.join(sandboxdir, so_fname)

  file sandbox_so_fname => [sandbox_so_fname.sub(sandboxdir, unpackdirmgw), File.dirname(sandbox_so_fname)] do |t|
    puts "patching manifest of #{t.name}"

    # The XML elements we want to add to the default MINGW manifest:
    new = <<~EOT
    <dependency>
      <dependentAssembly>
        <assemblyIdentity version="1.0.0.0" type="win32" name="#{File.basename(so_fname)}-assembly" />
      </dependentAssembly>
    </dependency>
    EOT

    ManifestUpdater.update_file(t.prerequisites.first, new, t.name)
  end
end

# Add a detached manifest file within the ext.so directory that lists all linked DLLs
ext_dll_defs.each do |so_fname, re|
  mani_path = File.join(sandboxdir, so_fname + "-assembly.manifest")
  e_dlls = ext_dlls.select { |dll| re =~ File.basename(dll) }

  file mani_path => [File.dirname(mani_path)] do |t|
    puts "generate #{t.name}"

    File.binwrite t.name, <<~EOT
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
      <assemblyIdentity type="win32" name="#{File.basename(so_fname)}-assembly" version="1.0.0.0"></assemblyIdentity>

      #{ e_dlls.map{|dll| %Q{<file name="#{File.basename(dll)}"/>} }.join }
    </assembly>
    EOT
  end
  self.sandboxfiles << mani_path
end


#################################################################################
# Add manifest to ruby.exe, rubyw.exe files pointing to DLLs in ruby_builtin_dlls
#################################################################################

core_dlls.each do |destpath|

  # Add tasks to write the DLLs into the sub directory
  new_destpath = File.join(File.dirname(destpath), "ruby_builtin_dlls", File.basename(destpath))
  file new_destpath => [destpath.sub(sandboxdir, unpackdirmgw), dlls_dir] do |t|
    cp(t.prerequisites.first, t.name)
  end

  # Move the DLLs in the dependent files list to the subdirectory
  self.sandboxfiles.delete(destpath)
  self.sandboxfiles << new_destpath
end

# Add a custom manifest to ruby.exe, rubyw.exe and libruby, so that they find the DLLs to be moved
self.sandboxfiles.select do |destpath|
  destpath =~ libruby_regex
end.each do |destpath|

  file destpath => [destpath.sub(sandboxdir, unpackdirmgw), bin_dir] do |t|
    puts "patching manifest of #{t.name}"

    # The XML elements we want to add to the default MINGW manifest:
    new = <<~EOT
      <dependency>
        <dependentAssembly>
          <assemblyIdentity version="1.0.0.0" type="win32" name="ruby_builtin_dlls" />
        </dependentAssembly>
      </dependency>
    EOT

    ManifestUpdater.update_file(t.prerequisites.first, new, t.name)
  end
end

# Add a detached manifest file within the sub directory that lists all DLLs in question
manifest2 = File.join(sandboxdir, "bin/ruby_builtin_dlls/ruby_builtin_dlls.manifest")
file manifest2 => [dlls_dir] do |t|
  puts "generate #{t.name}"
  File.binwrite t.name, <<~EOT
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
      <assemblyIdentity type="win32" name="ruby_builtin_dlls" version="1.0.0.0"></assemblyIdentity>

      #{ core_dlls.map{|dll| %Q{<file name="#{File.basename(dll)}"/>} }.join }
    </assembly>
  EOT
end
self.sandboxfiles << manifest2
