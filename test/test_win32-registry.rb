#frozen_string_literal: true
require "minitest/autorun"

class TestWin32Registry < Minitest::Test
  private def backslachs(path)
    path.gsub("/", "\\")
  end

  TEST_REGISTRY_KEY = "SOFTWARE/ruby-win32-registry-test/"

  def test_win32_registry
    skip "Older rubies are not yet patched" if RUBY_VERSION =~ /^2\.[4567]|^3\.[01]\./

    old_cp = `chcp`[/\d+/]
    `chcp 850`
    begin
      require "win32/registry"
      keys = []
      Win32::Registry::HKEY_CURRENT_USER.create(backslachs(TEST_REGISTRY_KEY)) do |reg|
        reg.create("abc EUR")
        reg.create("abc €")
        reg.each_key do |subkey|
          keys << subkey
        end
      end
      
      assert_equal [Encoding::UTF_8] * 2, keys.map(&:encoding)
      assert_equal ["abc EUR", "abc €"], keys
    ensure
      Win32::Registry::HKEY_CURRENT_USER.open(backslachs(File.dirname(TEST_REGISTRY_KEY))) do |reg|
        reg.delete_key File.basename(TEST_REGISTRY_KEY), true
      end
      `chcp #{old_cp}`
    end
  end
end
