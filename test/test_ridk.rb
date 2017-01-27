require "minitest/autorun"
require "tempfile"
require "yaml"
require "test/helper/msys"

class TestRidk < Minitest::Test
  include Helper::Msys

  def run_per_cmd(input)
    Tempfile.open(%w[test .cmd]) do |fd|
      fd.write(input)
      fd.close
      IO.popen(["cmd", "/c", fd.path]){|io| io.read }
    end
  end

  def setup
    RubyInstaller.disable_msys_apps
    @old_path = ENV['PATH']
  end

  def teardown
    ENV['PATH'] = @old_path
  end

  def test_ridk_enable
    skip unless File.directory?("C:/msys64")

    ENV['PATH'] += ";c:\\testpath"
    out = run_per_cmd <<-EOT
@call ridk enable > NUL
@echo PATH: %PATH%
@echo MSYSTEM: %MSYSTEM%
    EOT

    mingw = RUBY_PLATFORM =~ /x64/ ? "MINGW64" : "MINGW32"
    assert_match(/PATH: .*;C:\\msys64\\#{mingw}\\bin;C:\\msys64\\usr\\bin.*c:\\testpath$/i, out)
    assert_match(/MSYSTEM: #{mingw}/i, out)
  end

  def test_ridk_disable
    skip unless File.directory?("C:/msys64")

    out = run_per_cmd <<-EOT
@call ridk enable > NUL
@call ridk disable > NUL
@echo PATH: %PATH%
@echo MSYSTEM: %MSYSTEM%
    EOT

    refute_operator out.downcase, :include?, "c:\\msys64", "msys should be removed from the PATH"
    assert_operator out.downcase, :include?, "msystem: \n", "msystem should get deleted"
  end

  def test_ridk_help
    out = run_per_cmd <<-EOT
@call ridk help
    EOT

    %w[install enable disable exec help version].each do |op|
      assert_operator out, :include?, op
    end
  end

  def test_ridk_exec
    out = run_per_cmd <<-EOT
@call ridk exec pacman -h
    EOT

    assert_operator out, :include?, "pacman <operation>"
  end

  def test_ridk_version
    skip unless File.directory?("C:/msys64")

    out = run_per_cmd <<-EOT
@call ridk version
    EOT
    y = YAML.load(out)

    assert_equal y["ruby"]["version"], RUBY_VERSION
    assert_equal y["ruby"]["platform"], RUBY_PLATFORM
    refute_nil y["ruby_installer"]["version"]
    assert_match(/gcc/, y["cc"])
    assert_match(/bash/, y["sh"])
    assert_equal y["msys2"]["path"], "c:\\msys64"
    skip "Appveyors MSYS version is too old to have a components.xml" if ENV['APPVEYOR']
    assert_match(/MSYS/, y["msys2"]["title"])
    assert_match(/\d/, y["msys2"]["version"])
  end

  def test_ridk_version_without_msys
    out = simulate_no_msysdir do
      run_per_cmd <<-EOT
@call ridk version
      EOT
    end
    y = YAML.load(out)

    assert_equal y["ruby"]["version"], RUBY_VERSION
    assert_equal y["ruby"]["platform"], RUBY_PLATFORM
    refute_nil y["ruby_installer"]["version"]
    assert_nil y["msys2"]
  end
end
