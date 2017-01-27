require "ruby_installer"

module Helper
  module Msys
    private def clear_dir_cache
      ENV.delete('RI_DEVKIT')
      RubyInstaller.msys2_installation.reset_cache
    end

    private def remove_mingwdir
      RubyInstaller.msys2_installation.disable_dll_search_paths
    end

    private def simulate_no_msysdir
      clear_dir_cache
      RubyInstaller::Msys2Installation::MSYS2_INSTALL_KEY << "non-exist"
      File.rename("c:/msys64", "c:/msys64.ri_test") if File.exist?("c:/msys64")
      File.rename("c:/msys32", "c:/msys32.ri_test") if File.exist?("c:/msys32")
      begin
        yield
      ensure
        File.rename("c:/msys64.ri_test", "c:/msys64") if File.exist?("c:/msys64.ri_test")
        File.rename("c:/msys32.ri_test", "c:/msys32") if File.exist?("c:/msys32.ri_test")
        RubyInstaller::Msys2Installation::MSYS2_INSTALL_KEY.gsub!("non-exist", "")
        clear_dir_cache
      end
    end

    private def simulate_nonstd_msysdir
      clear_dir_cache
      RubyInstaller::Msys2Installation::DEFAULT_MSYS64_PATH << "non-exist"
      RubyInstaller::Msys2Installation::DEFAULT_MSYS32_PATH << "non-exist"

      yield

      clear_dir_cache
      RubyInstaller::Msys2Installation::DEFAULT_MSYS64_PATH.gsub!("non-exist", "")
      RubyInstaller::Msys2Installation::DEFAULT_MSYS32_PATH.gsub!("non-exist", "")
    end
  end
end
