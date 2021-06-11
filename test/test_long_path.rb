#frozen_string_literal: true
require "minitest/autorun"
require "tmpdir"

class TestStdlib < Minitest::Test
  LONG_PATH = Dir.mktmpdir("0123456789"*15)
  
  def test_mkdir
    n = File.join(LONG_PATH, "c"*150)
    Dir.mkdir n
    assert Dir.exist?(n)
    assert_operator 260, :<, n.size
  end
  
  def test_file_rw
    n = File.join(LONG_PATH, "d"*150)
    File.write n, "abc"
    assert_equal "abc", File.read(n)
    assert File.exist?(n)
    assert_operator 260, :<, n.size
  end
  
  def test_load
    n = File.join(LONG_PATH, "e"*150 + ".rb")
    File.write n, "def loaded_a; 41; end"
    assert load(n)
    assert_equal 41, loaded_a
    assert_operator 260, :<, n.size
  end
end
