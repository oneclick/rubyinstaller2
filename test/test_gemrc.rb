#frozen_string_literal: true
require "minitest/autorun"
require "yaml"

class TestGemrc < Minitest::Test
  def test_gemrc
    y = YAML.load_file(Gem::ConfigFile::SYSTEM_WIDE_CONFIG_FILE)
    assert_kind_of Hash, y, "a default gemrc file should have been generated at the very first rubygems call for security reasons"
  end
end
