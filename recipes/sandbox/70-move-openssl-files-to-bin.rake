# Move bundled OpenSSL related files to bin/lib subdirectory.
# This is necessary because libcrypt.dll and libssl.dll are located in bin/ruby_builtin_dlls and they search other dlls in ../lib

if package.rubyver2 >= "3.2"
  osl_files = %w[
    lib/engines-3/loader_attic.dll
    lib/engines-3/padlock.dll
    lib/ossl-modules/legacy.dll
  ]

  osl_files.each do |path|
    # Add tasks to write the DLLs into the sub directory
    destpath = File.join(sandboxdir, "bin", path)
    file destpath => [File.join(unpackdirmgw, path), File.dirname(destpath)] do |t|
      cp(t.prerequisites.first, t.name)
    end

    # Add the DLLs in the dependent files list to the subdirectory
    self.sandboxfiles << destpath
  end
end
