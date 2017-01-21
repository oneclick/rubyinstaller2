require "minitest/autorun"
require "ruby_installer"
require "fiddle"

class TestModule < Minitest::Test
  def assert_libtest_load_fails
    assert_raises(Fiddle::DLError) do
      Fiddle.dlopen("libtest.dll")
    end
  end

  def assert_libtest_load_fail2
    begin
      assert_libtest_load_fails
      yield
    ensure
      assert_libtest_load_fails
    end
  end

  def test_add_remove_dll_directory
    assert_libtest_load_fail2 do
      res = RubyInstaller.add_dll_directory("test/helper")
      Fiddle.dlopen("libtest.dll").close
      res.remove
    end
  end

  def test_add_remove_dll_directory_with_block
    assert_libtest_load_fail2 do
      RubyInstaller.add_dll_directory("test/helper") do |handle|
        assert_respond_to(handle, :remove)
        Fiddle.dlopen("libtest.dll").close
      end
    end
  end

  private def clear_dir_cache
    ENV.delete('RI_DEVKIT')
    RubyInstaller.class_variable_set('@@msys_path', nil)
  end

  private def remove_mingwdir
    dlldir = RubyInstaller.class_variable_get('@@mingwdir')
    dlldir.remove if dlldir
    RubyInstaller.class_variable_set('@@mingwdir', nil)
  end

  private def simulate_no_msysdir
    clear_dir_cache
    RubyInstaller::MSYS2_INSTALL_KEY << "non-exist"
    File.rename("c:/msys64", "c:/msys64.ri_test") if File.exist?("c:/msys64")
    File.rename("c:/msys32", "c:/msys32.ri_test") if File.exist?("c:/msys32")
    begin
      yield
    ensure
      File.rename("c:/msys64.ri_test", "c:/msys64") if File.exist?("c:/msys64.ri_test")
      File.rename("c:/msys32.ri_test", "c:/msys32") if File.exist?("c:/msys32.ri_test")
      RubyInstaller::MSYS2_INSTALL_KEY.gsub!("non-exist", "")
      clear_dir_cache
    end
  end

  private def simulate_nonstd_msysdir
    clear_dir_cache
    RubyInstaller::DEFAULT_MSYS64_PATH << "non-exist"
    RubyInstaller::DEFAULT_MSYS32_PATH << "non-exist"

    yield

    clear_dir_cache
    RubyInstaller::DEFAULT_MSYS64_PATH.gsub!("non-exist", "")
    RubyInstaller::DEFAULT_MSYS32_PATH.gsub!("non-exist", "")
  end

  # The following tests require that MSYS2 is installed on c:/msys64 per MSYS2-installer.
  def test_enable_msys_apps_with_msys_installed
    skip unless File.directory?("C:/msys64")
    RubyInstaller.disable_msys_apps
    refute_operator ENV['PATH'].downcase, :include?, "c:\\msys64", "no msys in the path at the beginning"

    out, err = capture_subprocess_io do
      system("touch", "--version")
    end
    refute_match(/GNU coreutils/, out, "touch.exe shoudn't be in the path after disable_msys_apps")

    RubyInstaller.enable_msys_apps
    assert_operator ENV['PATH'].downcase, :include?, "c:\\msys64", "msys should be in the path after enable_msys_apps"
    assert_equal ENV['RI_DEVKIT'].downcase, "c:\\msys64", "enable_msys_apps should set RI_DEVKIT"
    assert_equal ENV['MSYSTEM'], RUBY_PLATFORM =~ /x64/ ? "MINGW64" : "MINGW32", "enable_msys_apps should set MSYSTEM according to RUBY_PLATFORM"

    out, err = capture_subprocess_io do
      system("touch", "--version")
    end
    assert_match(/GNU coreutils/, out, "touch.exe shoud be found after enable_msys_apps")

    RubyInstaller.disable_msys_apps
    refute_operator ENV['PATH'].downcase, :include?, "c:\\msys64", "no msys in the path after disable_msys_apps"
    assert_nil ENV['RI_DEVKIT']
    assert_nil ENV['MSYSTEM']
  end

  def test_enable_msys_apps_without_msys_installed
    skip unless File.directory?("C:/msys64")
    simulate_no_msysdir do
      assert_raises(SystemExit, "should exit if no msys found") do
        assert_output(nil, /MSYS2 could not be found/) do
          RubyInstaller.enable_msys_apps
        end
      end
      refute_operator File, :exist?, "c:\\msys64", "simulate_no_msysdir should rename c:/msys64"
    end
  end

  def test_enable_msys_apps_with_msys_installed_at_nonstddir
    skip unless File.directory?("C:/msys64")
    skip "MSYS2 has no installation entry in the registry on appveyor" if ENV['APPVEYOR']
    RubyInstaller.disable_msys_apps
    refute_operator ENV['PATH'].downcase, :include?, "c:\\msys64", "no msys in the path at the beginning"

    simulate_nonstd_msysdir do
      RubyInstaller.enable_msys_apps
      assert_operator ENV['PATH'].downcase, :include?, "c:\\msys64", "should find msys by looking into the registry"

      RubyInstaller.disable_msys_apps
      refute_operator ENV['PATH'].downcase, :include?, "c:\\msys64", "should have removed the msys path"
    end
  end

  def test_enable_dll_search_paths_with_msys_installed
    skip unless File.directory?("C:/msys64")
    remove_mingwdir
    vars1 = %w[PATH RI_DEVKIT MSYSTEM].map{|var| ENV[var] }

    # Double calling shouldn't matter
    RubyInstaller.enable_dll_search_paths
    RubyInstaller.enable_dll_search_paths
    Fiddle.dlopen("libobjc-4").close
    remove_mingwdir
    assert_raises(Fiddle::DLError) do
      Fiddle.dlopen("libobjc-4").close
    end

    vars2 = %w[PATH RI_DEVKIT MSYSTEM].map{|var| ENV[var] }
    assert_equal vars1, vars2, "env variables should be unchanged"
  end

  def test_enable_dll_search_paths_without_msys_installed
    skip unless File.directory?("C:/msys64")
    simulate_no_msysdir do
      RubyInstaller.enable_dll_search_paths
      assert_raises(Fiddle::DLError, "enable_dll_search_paths should succeed, but without effect") do
        Fiddle.dlopen("libobjc-4").close
      end
    end
  end

  def test_enable_dll_search_paths_with_msys_installed_at_nonstddir
    skip unless File.directory?("C:/msys64")
    skip "MSYS2 has no installation entry in the registry on appveyor" if ENV['APPVEYOR']
    simulate_nonstd_msysdir do
      RubyInstaller.enable_dll_search_paths
      Fiddle.dlopen("libobjc-4").close
      remove_mingwdir
    end
  end
end
