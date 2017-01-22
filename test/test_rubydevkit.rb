require "minitest/autorun"
require "tempfile"

class TestRubydevkit < Minitest::Test
  def test_rubydevkit_without_params
    skip unless File.directory?("C:/msys64")

    old = ENV['PATH']
    ENV['PATH'] += ";c:\\testpath"
    out = Tempfile.open(%w[test .cmd]) do |fd|
      fd.write <<-EOT
@call rubydevkit
@echo PATH: %PATH%
@echo MSYSTEM: %MSYSTEM%
      EOT
      fd.close
      IO.popen(["cmd", "/c", fd.path]){|io| io.read }
    end

    mingw = RUBY_PLATFORM =~ /x64/ ? "MINGW64" : "MINGW32"
    assert_match(/PATH: .*;C:\\msys64\\#{mingw}\\bin;C:\\msys64\\usr\\bin.*c:\\testpath$/i, out)
    assert_match(/MSYSTEM: #{mingw}/i, out)
    ENV['PATH'] = old
  end
end
