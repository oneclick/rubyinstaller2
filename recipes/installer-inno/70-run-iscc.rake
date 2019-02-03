file installer_exe => (sandbox_task.sandboxfiles + [iss_compiler.result_filename, filelist_iss]) do
  tries = 3
  while (tries-=1) > 0
    sh "cmd", "/c", "iscc", iss_compiler.result_filename, "/Q", "/O#{File.dirname(installer_exe)}", "/F#{File.basename(installer_exe, ".exe")}" do |ok, res|
        p [ok, res]
      next if !ok #&& res.exitstatus == 3
    end
    break
  end
end
