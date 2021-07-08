require "ruby_installer/runtime"

module Helper
  module Msys
    @@msys_path = ENV.fetch('RI_DEVKIT'){ "c:\\msys64" }.downcase.freeze

    private def msys_path
      @@msys_path
    end

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
      File.rename(msys_path, "c:/msys2.ri_test") if File.exist?(msys_path)
      begin
        yield
      ensure
        File.rename("c:/msys64.ri_test", "c:/msys64") if File.exist?("c:/msys64.ri_test")
        File.rename("c:/msys32.ri_test", "c:/msys32") if File.exist?("c:/msys32.ri_test")
        File.rename("c:/msys2.ri_test", msys_path) if File.exist?("c:/msys2.ri_test")
        RubyInstaller::Runtime::Msys2Installation::MSYS2_INSTALL_KEY.gsub!("non-exist", "")
        clear_dir_cache
      end
    end

    private def with_env(hash)
      olds = hash.map{|k, _| [k, ENV[k.to_s]] }
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
