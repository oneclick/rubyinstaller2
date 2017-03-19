file installer_exe => (sandbox_task.sandboxfiles + [iss_compiler.result_filename, filelist_iss]) do
  sh "cmd", "/c", "iscc", iss_compiler.result_filename, "/Q", "/dRubyVersion=#{package.rubyver}", "/dRubyBuildPlatform=#{package.ruby_arch}", "/dRubyShortPlatform=-#{package.arch}", "/dDefaultDirName=#{package.default_instdir}", "/dPackageRelease=#{package.pkgrel}", "/O#{File.dirname(installer_exe)}", "/F#{File.basename(installer_exe, ".exe")}"
end
