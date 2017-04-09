require "ruby_installer/runtime"

module Helper
  module Msys
    private def clear_dir_cache
      ENV.delete('RI_DEVKIT')
      RubyInstaller::Runtime.msys2_installation.reset_cache
    end

    private def remove_mingwdir
      RubyInstaller::Runtime.msys2_installation.disable_dll_search_paths
    end

    private def simulate_no_msysdir
      clear_dir_cache
      RubyInstaller::Runtime::Msys2Installation::MSYS2_INSTALL_KEY << "non-exist"
      File.rename("c:/msys64", "c:/msys64.ri_test") if File.exist?("c:/msys64")
      File.rename("c:/msys32", "c:/msys32.ri_test") if File.exist?("c:/msys32")
      begin
        yield
      ensure
        File.rename("c:/msys64.ri_test", "c:/msys64") if File.exist?("c:/msys64.ri_test")
        File.rename("c:/msys32.ri_test", "c:/msys32") if File.exist?("c:/msys32.ri_test")
        RubyInstaller::Runtime::Msys2Installation::MSYS2_INSTALL_KEY.gsub!("non-exist", "")
        clear_dir_cache
      end
    end

    private def with_env(hash)
      olds = hash.each{|k, _| [k, ENV[k.to_s]] }
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
  end
end
