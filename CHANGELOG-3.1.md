## RubyInstaller-3.1.2-1 - 2022-04-19

### Changed
- Update to ruby-3.1.2, see [release notes](https://www.ruby-lang.org/en/news/2022/04/12/ruby-3-1-2-released/).
- Update of the SSL CA certificate list.
- Update the bundled MSYS2 keyring package.

### Removed
- No longer respond to MSYSTEM environment variable for setting a cross build environment. #269


## RubyInstaller-3.1.1-1 - 2022-02-18

### Changed
- Update to ruby-3.1.1, see [release notes](https://www.ruby-lang.org/en/news/2022/02/18/ruby-3-1-1-released/).
- Fix a runtime error when running CGI in WEBrick http server. #260
- Backport a patch for Reline to fix AltGr on European keyboards. #259


## RubyInstaller-3.1.0-1 - 2021-12-31

This is the first release based on ruby-3.1.0: https://www.ruby-lang.org/en/news/2021/12/25/ruby-3-1-0-released/

### Changes compared to RubyInstaller-3.0.3-1
- Change C-runtime from MSVCRT to UCRT of x64 version.
  See the feature request here: https://bugs.ruby-lang.org/issues/17845
  UCRT is the modern C-runtime of Windows replacing the legacy MSVCRT.
  There are several platform strings that change with the new release.
  They are summarized here: https://github.com/ruby/ruby/pull/4599
  In particular the ruby and gem platform is now "x64-mingw-ucrt" instead of "x64-mingw32" and the MSYS2 package prefix is now `mingw-w64-ucrt-x86_64-`.
- No longer require fiddle before booting Rubygems, but use the new C-extension "win32/dll_directory".
  Fixes #251
