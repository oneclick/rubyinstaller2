file installer_exe => (sandbox_task.sandboxfiles + [iss_compiler.result_filename, filelist_iss]) do
  sh "cmd", "/c", "iscc", iss_compiler.result_filename, "/Q", "/O#{File.dirname(installer_exe)}", "/F#{File.basename(installer_exe, ".exe")}"
end
