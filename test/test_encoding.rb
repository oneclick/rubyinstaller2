require "minitest/autorun"

class TestEncoding < Minitest::Test
  def test_default_external
    assert_equal Encoding::UTF_8, Encoding.default_external
  end

  def test_default_internal
    assert_nil Encoding.default_internal
  end

  def test_default_external_file_read
    content = File.read(__FILE__)
    assert_equal Encoding::UTF_8, content.encoding
    assert_match(/ÄöüßЖ/, content)
  end

  def test__encoding__
    assert_equal Encoding::UTF_8, __ENCODING__
  end
end
