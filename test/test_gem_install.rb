require "minitest/autorun"

class TestGemInstall < Minitest::Test
  def test_gem_install
    res = system <<-EOT.gsub("\n", "&")
cd test/helper/testgem
gem build testgem.gemspec
gem install testgem-1.0.0.gem --verbose
    EOT
    assert_equal true, res, "shell commands should succeed"

    out = IO.popen("ruby -rtestgem -e \"puts 'testgem successfully installed and loaded'\"") do |io|
      io.read
    end
    assert_match(/successfully installed and loaded/, out)
  end
end
