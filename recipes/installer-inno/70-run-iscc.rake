file installer_exe => (sandbox_task.sandboxfiles + [iss_compiler.result_filename, filelist_iss]) do
  tries = 10
  loop do
    ok, res = sh "cmd", "/c", "iscc", iss_compiler.result_filename, "/Q", "/O#{File.dirname(installer_exe)}", "/F#{File.basename(installer_exe, ".exe")}" do |ok_, res_|
      [ok_, res_]
    end
    if !ok
      if (tries-=1) > 0 && res.exitstatus == 2
        # Handle "Out of memory" which happens in docker, when several "docker run" are running
        $stderr.puts "Retry iscc due to failure #{res.inspect}"
        sleep 5
      else
        raise "iscc failed #{res.inspect}"
      end
    else
      break
    end
  end
end
