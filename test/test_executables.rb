#frozen_string_literal: true
require "minitest/autorun"
require "fileutils"

class TestExecutables < Minitest::Test
  def test_bundler
    skip if RUBY_VERSION =~ /^2\.[345]\./
    # bundler was added in ruby-2.6
    assert_match(/Bundler version|^4\.\d/, `bundle --version`)
    assert_match(/Bundler version|^4\.\d/, `bundler --version`)
  end

  def test_gem
    assert_match(/\d+\.\d+\.\d+/, `gem --version`)
  end

  def test_erb
    res = IO.popen("erb", "w+") do |io|
      io.write "a<%=1+2%>b"
      io.close_write
      io.read
    end
    assert_match(/a3b/, res)
  end

  def test_irb
    res = IO.popen("irb", "w+") do |io|
      io.write "'ab'*3\n"
      io.close_write
      io.read
    end
    assert_match(/\"ababab\"/, res)
  end

  def test_rake
    assert_match(/rake, version/, `rake --version`)
  end

  def test_rdoc
    assert_match(/\d+\.\d+\.\d+/, `rdoc --version`)
  end

  def test_ri
    assert_match(/A String object .* sequence of bytes/, `ri String 2>&1`)
  end

  def test_ruby
    FileUtils.rm_f("test_ruby♥.log")
    system(%q[ruby -e "File.write(ARGV[0],'xy')" test_ruby♥.log])
    assert_equal("xy", File.read("test_ruby♥.log"))
  end

  def test_rubyw
    FileUtils.rm_f("test_rubyw♥.log")
    system(%q[rubyw -e "File.write(ARGV[0],'xy')" test_rubyw♥.log])
    assert_equal("xy", File.read("test_rubyw♥.log"))
  end

  unless RUBY_VERSION =~ /^2\.[3456]\./
    def test_racc
      assert_match(/racc.*\d+\.\d+\.\d+/, `racc --version`)
    end
  end

  unless RUBY_VERSION =~ /^2\.[34567]\./
    def test_rbs
      assert_match(/rbs.*\d+\.\d+\.\d+/, `rbs --version`)
    end

    def test_typeprof
      assert_match(/typeprof.*\d+\.\d+\.\d+/, `typeprof --version`)
    end
  end
end
