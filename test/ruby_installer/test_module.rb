require "minitest/autorun"
require "ruby_installer/runtime"
require "fiddle"
require "test/helper/msys"
require "rbconfig"

class TestModule < Minitest::Test
  include Helper::Msys

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
      res = RubyInstaller::Runtime.add_dll_directory("test/helper")
      Fiddle.dlopen("libtest.dll").close
      res.remove
    end
  end

  def test_add_remove_dll_directory_with_block
    assert_libtest_load_fail2 do
      RubyInstaller::Runtime.add_dll_directory("test/helper") do |handle|
        assert_respond_to(handle, :remove)
        Fiddle.dlopen("libtest.dll").close
      end
    end
  end

  def test_add_dll_directory_non_exist
    err = assert_raises(RubyInstaller::Runtime::DllDirectory::Error) do
      RubyInstaller::Runtime.add_dll_directory("C:/invalid_path")
    end
    assert_match(/C:.invalid_path/, err.to_s)
  end

  def test_RUBY_DLL_PATH
    ENV['RUBY_DLL_PATH'] = "non-exist;#{ File.expand_path("test/helper") };another-dummy"
    begin
      res = IO.popen("ruby -rfiddle -e \"p Fiddle.dlopen('libtest.dll')\"", &:read)
      assert_match(/Fiddle::Handle/, res)
    ensure
      ENV.delete('RUBY_DLL_PATH')
    end
  end

  # The following tests require that MSYS2 is installed on c:/msys64 per MSYS2-installer.
  def test_enable_msys_apps_with_msys_installed
    skip unless File.directory?("C:/msys64")
    RubyInstaller::Runtime.disable_msys_apps
    refute_operator ENV['PATH'].downcase, :include?, "c:\\msys64", "msys in the path at the start of the test"

    out, err = capture_subprocess_io do
      system("touch", "--version")
    end
    refute_match(/GNU coreutils/, out, "touch.exe shoudn't be in the path after disable_msys_apps")

    RubyInstaller::Runtime.enable_msys_apps
    assert_operator ENV['PATH'].downcase, :include?, "c:\\msys64", "msys should be in the path after enable_msys_apps"
    assert_equal "c:\\msys64", ENV['RI_DEVKIT'].downcase, "enable_msys_apps should set RI_DEVKIT"
    assert_equal RUBY_PLATFORM =~ /x64/ ? "MINGW64" : "MINGW32", ENV['MSYSTEM'], "enable_msys_apps should set MSYSTEM according to RUBY_PLATFORM"
    assert_match(/./, ENV['LANG'], "enable_msys_apps should set LANG")

    out, err = capture_subprocess_io do
      system("touch", "--version")
    end
    assert_match(/GNU coreutils/, out, "touch.exe shoud be found after enable_msys_apps")

    RubyInstaller::Runtime.disable_msys_apps
    refute_operator ENV['PATH'].downcase, :include?, "c:\\msys64", "no msys in the path after disable_msys_apps"
    assert_nil ENV['RI_DEVKIT']
    assert_nil ENV['MSYSTEM']
  end

  def test_enable_msys_apps_without_msys_installed
    skip unless File.directory?("C:/msys64")
    simulate_no_msysdir do
      assert_raises(SystemExit, "should exit if no msys found") do
        assert_output(nil, /MSYS2 could not be found/) do
          RubyInstaller::Runtime.enable_msys_apps
        end
      end
      refute_operator File, :exist?, "c:\\msys64", "simulate_no_msysdir should rename c:/msys64"
    end
  end

  def test_iterate_msys_paths
    clear_dir_cache
    RbConfig::TOPDIR << "/longer/path/ruby"
    paths = []
    begin
      assert_raises(RubyInstaller::Runtime::Msys2Installation::MsysNotFound) do
        with_env({PATH: "D:/xyz/abc/def;E:/"}) do
          RubyInstaller::Runtime.msys2_installation.iterate_msys_paths do |path|
            paths << path
          end
        end
      end
      paths = paths.map{|path| path.gsub("\\", "/").gsub(File.dirname(RbConfig::TOPDIR), "<inst>") }
    ensure
      RbConfig::TOPDIR.gsub!("/longer/path/ruby", "")
      clear_dir_cache
    end

    # Test for Paths in the ruby install dir, for default paths and for the PATH dirs.
    # MSYS paths from the registry are not (yet) tested.
    min_paths = %w[
      <inst>/ruby/msys64
      <inst>/ruby/msys32
      <inst>/msys64
      <inst>/msys32
      c:/msys64
      c:/msys32
      D:/xyz/abc/def
      E:/
    ]
    assert_equal( min_paths, paths & min_paths )
  end

  def test_enable_dll_search_paths_with_msys_installed
    skip unless File.directory?("C:/msys64")
    remove_mingwdir
    vars1 = %w[PATH RI_DEVKIT MSYSTEM].map{|var| ENV[var] }

    # Double calling shouldn't matter
    RubyInstaller::Runtime.enable_dll_search_paths
    RubyInstaller::Runtime.enable_dll_search_paths
    Fiddle.dlopen("libobjc-4").close
    remove_mingwdir
    # PATH based DLL search makes reliable anti-pattern impossible
    unless ENV['RI_FORCE_PATH_FOR_DLL'] == '1'
      assert_raises(Fiddle::DLError) do
        Fiddle.dlopen("libobjc-4").close
      end
    end

    vars2 = %w[PATH RI_DEVKIT MSYSTEM].map{|var| ENV[var] }
    assert_equal vars1, vars2, "env variables should be unchanged"
  end

  def test_enable_dll_search_paths_without_msys_installed
    skip unless File.directory?("C:/msys64")
    simulate_no_msysdir do
      RubyInstaller::Runtime.enable_dll_search_paths
      assert_raises(Fiddle::DLError, "enable_dll_search_paths should succeed, but without effect") do
        Fiddle.dlopen("libobjc-4").close
      end
    end
  end

  def test_gem_version
    skip "This should be moved into a separate test for the Build namespace"
    assert_match(/\A\d+\.\d+\.\d+\z/, RubyInstaller::Build::GEM_VERSION)
  end

  def test_git_commit
    assert_match(/\A[0-9a-f]{7}\z/i, RubyInstaller::Runtime::GIT_COMMIT)
  end

  def test_package_version
    assert_match(/\A\d+\.\d+\.\d+(\.[a-z]\w*)?-\w+\z/, RubyInstaller::Runtime::PACKAGE_VERSION)
  end
end
