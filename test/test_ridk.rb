require "minitest/autorun"
require "tempfile"
require "yaml"
require "test/helper/msys"

module RidkTests
  include Helper::Msys

  def setup
    @old_path = ENV['PATH']
    RubyInstaller::Runtime.disable_msys_apps
  end

  def teardown
    ENV['PATH'] = @old_path
    ENV.delete 'MSYSTEM'
  end

  def test_ridk_enable
    skip unless File.directory?(msys_path)

    ENV['PATH'] += ';"c:\\testpath"'
    out = run_output_vars([], ["ridk enable"], %w[PATH MSYSTEM])

    msystem = case RUBY_PLATFORM
      when "x64-mingw32" then "MINGW64"
      when "x64-mingw-ucrt" then "UCRT64"
      when "i386-mingw32" then "MINGW32"
    end
    assert_match(/PATH: .*;#{Regexp.escape(msys_path)}\\#{msystem}\\bin;#{Regexp.escape(msys_path)}\\usr\\bin.*;"c:\\testpath"$/i, out)
    assert_match(/MSYSTEM: #{msystem}/i, out)
  end

  def test_ridk_enable_with_MSYSTEM
    skip unless File.directory?(msys_path)

    ENV['PATH'] += ';"c:\\testpath"'
    ENV['MSYSTEM'] = 'MINGW32'
    out = run_output_vars([], ["ridk enable ucrt64"], %w[PATH MSYSTEM MINGW_PACKAGE_PREFIX])

    assert_match(/PATH: .*;#{Regexp.escape(msys_path)}\\ucrt64\\bin;#{Regexp.escape(msys_path)}\\usr\\bin.*;"c:\\testpath"$/i, out)
    assert_match(/MSYSTEM: UCRT64/i, out)
    assert_match(/MINGW_PACKAGE_PREFIX: mingw-w64-ucrt-x86_64/i, out)
  end

  def test_ridk_enable_with_arg
    skip unless File.directory?(msys_path)

    ENV['PATH'] += ';"c:\\testpath"'
    ENV['MSYSTEM'] = 'UCRT64'
    out = run_output_vars([], ["ridk enable mingw32"], %w[PATH MSYSTEM MINGW_PACKAGE_PREFIX])

    assert_match(/PATH: .*;#{Regexp.escape(msys_path)}\\mingw32\\bin;#{Regexp.escape(msys_path)}\\usr\\bin.*;"c:\\testpath"$/i, out)
    assert_match(/MSYSTEM: MINGW32/i, out)
    assert_match(/MINGW_PACKAGE_PREFIX: mingw-w64-i686/i, out)
  end

  def test_ridk_disable
    skip unless File.directory?(msys_path)

    out = run_output_vars([], ["ridk enable", "ridk disable"], %w[PATH MSYSTEM])

    refute_operator out.downcase, :include?, msys_path, "msys should be removed from the PATH"
    assert_operator out.downcase, :include?, "msystem: \n", "msystem should get deleted"
  end

  def test_ridk_help
    out = run_capture_output "ridk help"

    %w[install enable disable exec help version].each do |op|
      assert_operator out, :include?, op
    end
  end

  def test_ridk_exec
    out = run_capture_output "ridk exec pacman -h"

    assert_operator out, :include?, "pacman <operation>"
  end

  def test_ridk_version
    skip unless File.directory?(msys_path)

    out = run_capture_output "ridk version"
    y = YAML.load(out)

    refute_nil y["ruby"]["path"]
    assert_equal RUBY_VERSION, y["ruby"]["version"]
    assert_equal RUBY_PLATFORM, y["ruby"]["platform"]
    refute_nil y["ruby_installer"]["package_version"]
    refute_nil y["ruby_installer"]["git_commit"]
    assert_match(/gcc.*MSYS2/, y["cc"])
    assert_match(/bash.*pc-msys/, y["sh"])
    assert_match(/windows/i, y["os"])
    assert_equal msys_path, y["msys2"]["path"].downcase
    skip "Appveyors MSYS version is too old to have a components.xml" if ENV['APPVEYOR'] || ENV['GITHUB_ACTION']
    assert_match(/MSYS/, y["msys2"]["title"])
    assert_match(/\d/, y["msys2"]["version"])
  end

  def test_ridk_version_without_msys
    out = simulate_no_msysdir do
      run_capture_output "ridk version"
    end
    y = YAML.load(out)

    assert_equal RUBY_VERSION, y["ruby"]["version"]
    assert_equal RUBY_PLATFORM, y["ruby"]["platform"]
    assert_match(/gcc.*MSYS2/, y["ruby"]["cc"] || y["cc"])
    refute_nil y["ruby_installer"]["package_version"]
    refute_nil y["ruby_installer"]["git_commit"]
    assert_nil y["msys2"]
  end

  def test_ridk_use_list
    _path, _, _, regex = find_alternative_ruby

    out = run_capture_output("ridk use list 2>&1")
    assert_match(regex, out)
  end

  def test_ridk_use_help
    out = run_capture_output("ridk use help 2>&1")
    assert_match(/installed ruby versions/i, out)
  end

  def test_ridk_use_update
    out = run_capture_output("ridk use update 2>&1")
    assert_match(/rubies.yml/, out)
    / (?<rubiesyml>[-\w\/\\:]*rubies.yml)/ =~ out
    array = YAML.load_file(rubiesyml)
    assert_kind_of Array, array

    path, = find_alternative_ruby
    assert_operator array, :include?, path
  end

  def test_ridk_use_index
    path, = find_alternative_ruby
    with_ruby_dirs([path]) do
      out = run_output_vars(%w[PATH], ["ridk use 1"], %w[PATH])
      path1, path2 = out.scan(/^PATH:.*/)
      /(?<old_ruby>\w:.*?ruby.*?bin)/i =~ path1
      refute_nil old_ruby, "there should be default ruby in the PATH"
      assert_operator path2.downcase, :include?, "\\ridk_use;", "ridk_use should be in the PATH"
      assert_operator path2.downcase, :include?, "#{path.downcase.gsub("/", "\\")}\\bin;", "selected ruby should be in the PATH"
      refute_operator path2.downcase, :include?, old_ruby, "old ruby should be removed from the PATH"
    end
  end

  def test_ridk_use_regex
    path, selector, = find_alternative_ruby
    out = run_output_vars(%w[PATH], ["ridk use #{selector}"], %w[PATH])
    path1, path2 = out.scan(/^PATH:.*/)
    /(?<old_ruby>\w:.*?ruby.*?bin)/i =~ path1
    refute_nil old_ruby, "there should be default ruby in the PATH"
    assert_operator path2.downcase, :include?, "\\ridk_use;", "ridk_use should be in the PATH"
    assert_operator path2.downcase, :include?, "#{path.downcase.gsub("/", "\\")}\\bin;", "selected ruby should be in the PATH"
    refute_operator path2.downcase, :include?, old_ruby, "old ruby should be removed from the PATH"
  end

  def test_ridk_use_then_ridk_version
    _path, selector, regex, = find_alternative_ruby

    out = run_in_shells("ridk use \"#{selector}\" && ridk version",
                        "ridk use \"#{selector}\"; if($?){ ridk version }")
    assert_match(/package_version: #{regex}/, out, "ridk version should report about the selected ruby")
  end

  def find_alternative_ruby
    ar = [
      ["C:/Ruby30-x64", "/30-x64/", "3\.0\.", /C:\/Ruby30-x64\s+ruby 3\.0\..*x64-mingw32/i, "3.0 x64-mingw32"],
      ["C:/Ruby30", "/30$/", "3\.0\.", /C:\/Ruby30\s+ruby 3\.0\..*i386-mingw32/i, "3.0 i386-mingw32"],
    ].find do |path, selector, regex_rver, regex_list, verplat|
      File.directory?(path) && verplat != "#{RUBY_VERSION.split(".").map(&:to_i)[0,2].join(".")} #{RUBY_PLATFORM}"
    end
    skip "No alternative ruby found" unless ar
    ar
  end

  def with_ruby_dirs(dirs)
    dirs.each do |dir|
      skip unless File.directory?(dir)
    end

    rubies = dirs
    tmpyml = Tempfile.new(%w[rubies yml])
    tmpyml.write YAML.dump(rubies)
    tmpyml.close
    ENV['RIDK_USE_RUBIES'] = tmpyml.path
    yield
  ensure
    ENV.delete 'RIDK_USE_RUBIES'
  end
end

class TestRidkCmd < Minitest::Test
  include Helper::Msys
  include RidkTests

  def vars_to_print(vars)
    vars.map do |var|
      "@echo #{var}: %#{var}%"
    end.join("\n")
  end

  def run_output_vars(before_vars, commands, after_vars)
    jc = commands.map do |c|
      "@call #{c} > NUL"
    end.join("\n")

    run_in_shells <<-EOCMD, nil
#{ vars_to_print(before_vars) }
#{ jc }
#{ vars_to_print(after_vars) }
    EOCMD
  end

  def run_capture_output(command)
    run_in_shells <<-EOCMD, nil
@call #{command}
    EOCMD
  end

  def run_in_shells(cmd, ps1)
    Tempfile.open(%w[test .cmd]) do |fd|
      fd.write(cmd)
      fd.close
      IO.popen(["cmd", "/c", fd.path]){|io| io.read }
    end
  end

  def test_ridk_install
    assert system("ridk install msys2")
  end
end

class TestRidkPs1 < Minitest::Test
  include Helper::Msys
  include RidkTests

  def vars_to_print(vars)
    vars.map do |var|
      "Write-Output ('#{var}: ' + $env:#{var})"
    end.join("\n")
  end

  def run_output_vars(before_vars, commands, after_vars)
    jc = commands.map do |c|
      "$out = & #{c}"
    end.join("\n")

    run_in_shells nil, <<-EOPS1
#{ vars_to_print(before_vars) }
#{ jc }
#{ vars_to_print(after_vars) }
    EOPS1
  end

  def run_capture_output(command)
    run_in_shells nil, <<-EOPS1
(#{command} | %{ "$_" })
    EOPS1
  end

  def run_in_shells(cmd, ps1)
    Tempfile.open(%w[test .ps1]) do |fd|
      fd.write(ps1)
      fd.close
      IO.popen(["powershell", "-executionpolicy", "Bypass", "-File", fd.path]){|io| io.read }
    end
  end
end
