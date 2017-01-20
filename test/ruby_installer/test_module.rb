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
end
