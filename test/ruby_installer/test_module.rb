require "minitest/autorun"
require "ruby_installer"
require "fiddle"

class TestModule < Minitest::Test
  def assert_libtest_load_fails
    assert_raises(Fiddle::DLError) do
      Fiddle.dlopen("libtest.dll")
    end
  end

  def test_add_remove_dll_directory
    assert_libtest_load_fails

    res = RubyInstaller.add_dll_directory("test/helper")
    Fiddle.dlopen("libtest.dll").close
    res.remove

    assert_libtest_load_fails
  end

  def test_add_remove_dll_directory_with_block
    assert_libtest_load_fails

    RubyInstaller.add_dll_directory("test/helper") do |handle|
      assert_respond_to(handle, :remove)
      Fiddle.dlopen("libtest.dll").close
    end

    assert_libtest_load_fails
  end
end
