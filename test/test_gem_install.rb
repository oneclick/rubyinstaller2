require "minitest/autorun"
require "fileutils"

class TestGemInstall < Minitest::Test
  # Remove installed packages per:
  #   pacman -R %MINGW_PACKAGE_PREFIX%-libmowgli %MINGW_PACKAGE_PREFIX%-libguess ed
  def test_gem_install
    res = system <<-EOT.gsub("\n", "&")
      cd test/helper/testgem
      gem build testgem.gemspec
      gem install testgem-1.0.0.gem --verbose
    EOT
    assert res, "shell commands should succeed"

    out = IO.popen("ruby -rtestgem -e \"puts Libguess.determine_encoding('abc', 'Greek')\"", &:read)
    assert_match(/UTF-8/, out.scrub, "call the ruby API of the testgem")

    out = RubyInstaller::Runtime.msys2_installation.with_msys_apps_enabled do
      IO.popen("ed --version", &:read)
    end
    assert_match(/GNU ed/, out.scrub, "execute the installed MSYS2 program, requested by the testgem")

    out = IO.popen("testgem-exe", &:read)
    assert_match(/UTF-8/, out.scrub, "execute the bin file of the testgem")

    assert system("gem uninstall testgem --executables --force"), "uninstall testgem"
    FileUtils.rm("test/helper/testgem/testgem-1.0.0.gem")
  end

  def test_bundle_install
    remove_pacman_packages_for_test
    FileUtils.mkdir_p "test/helper/testgem/vendor/cache"
    res = system <<-EOT.gsub("\n", "&")
      cd test/helper/testgem
      gem build testgem.gemspec
      copy /b testgem-1.0.0.gem "vendor/cache/"
      bundle install --local
    EOT
    assert res, "shell commands should succeed"

    out = IO.popen("bundle exec ruby -rtestgem -e \"puts Libguess.determine_encoding('abc', 'Greek')\"", chdir: "test/helper/testgem", &:read)
    assert_match(/UTF-8/, out.scrub, "call the ruby API of the testgem")

    assert system("gem uninstall testgem --executables --force"), "uninstall testgem"
    FileUtils.rm("test/helper/testgem/testgem-1.0.0.gem")
  end

  if RUBY_VERSION < "3.0"
    TESTUSER = "ritestuser"
  else
    TESTUSER = "ritästuser"
  end

  def with_test_user(testname: nil)
    testname ||= caller[0][/[`#].*?'/][1..-2]

    if ENV['USERNAME'] == TESTUSER
      puts "====HOME:#{ENV['USERPROFILE']}===="
      yield
    else
      system("net user #{TESTUSER} /del >NUL")
      system("net user #{TESTUSER} \"Password123+\" /add") || raise

      require "win32/process"

      stdout_read, stdout_write = IO.pipe
      cmd = "ruby #{__FILE__} -v -n #{testname}"
      Process.create command_line: cmd,
          with_logon: TESTUSER,
          password: "Password123+",
          cwd: Dir.pwd,
          startup_info: { stdout: stdout_write, stderr: stdout_write }

      stdout_write.close
      out = stdout_read.read
      assert_match(/ 0 failures, 0 errors/, out.scrub, "process running under #{TESTUSER}")
      puts out

      if out =~ /====HOME:(.*)====/
        FileUtils.rm_rf($1)
      end
    end
  end

  private def remove_pacman_packages_for_test
    RubyInstaller::Runtime.msys2_installation.with_msys_apps_enabled do
      system("pacman -R --noconfirm %MINGW_PACKAGE_PREFIX%-libmowgli %MINGW_PACKAGE_PREFIX%-libguess ed")
    end
  end


  def test_user_gem_install
    unless ENV['USERNAME'] == TESTUSER
      RubyInstaller::Runtime.msys2_installation.with_msys_apps_enabled do
        system("pacman -S --needed --noconfirm %MINGW_PACKAGE_PREFIX%-libmowgli %MINGW_PACKAGE_PREFIX%-libguess ed")
      end
    end
    with_test_user do
      test_gem_install
    end
    unless ENV['USERNAME'] == TESTUSER
      remove_pacman_packages_for_test
    end
  end

  def test_user_msys_tmp
    with_test_user do
      RubyInstaller::Runtime.msys2_installation.with_msys_apps_enabled do
        out = IO.popen('sh -c "echo works >/tmp/ritestfile && cat /tmp/ritestfile && rm /tmp/ritestfile"', &:read)
        assert_match(/works/, out.scrub)
        assert_equal 0, $?.exitstatus
      end
    end
  end

  def test_user_bundler
    with_test_user do
      require "tmpdir"

      Dir.mktmpdir("ritest") do |dir|
        pwd = Dir.pwd
        Dir.chdir dir
        File.write("Gemfile", "source 'https://rubygems.org'; gem 'diff-lcs'")

        out = IO.popen('bundle install', &:read)
        assert_match(/Bundle complete!/, out.scrub)

        out = IO.popen('ldiff --version 2>&1', &:read)
        assert_match(/Diff::LCS/, out.scrub)

        assert system("gem uninstall diff-lcs --executables --force"), "uninstall diff-lcs"
      ensure
        Dir.chdir pwd
      end
    end
  end
end
