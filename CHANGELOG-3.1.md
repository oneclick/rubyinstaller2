## RubyInstaller-3.1.4-1 - 2023-04-01

### Changed
- Update to ruby-3.1.4, see [release notes](https://www.ruby-lang.org/en/news/2023/03/30/ruby-3-1-4-released/).
- Update to OpenSSL-1.1.1t.


## RubyInstaller-3.1.3-1 - 2022-11-27

### Added
- Restrict write permissions to the installing user.
  For several reasons we use `C:/RubyXXX` direcory by default but not `C:/Program Files` (see: oneclick/rubyinstaller#135 ).
  Using an install path under `C:/` previously inherited write permissions for everyone, which compromised security in a multi user environment.
- `ridk use` Add options to store the change permanently in the user or system environment variables. #314

### Changed
- Update to ruby-3.1.3, see [release notes](https://www.ruby-lang.org/en/news/2022/11/24/ruby-3-1-3-released/).
- Update of the SSL CA certificate list.
- Update the bundled MSYS2 keyring package.
- Fix start menu entry for rubygems-server and irb.
- Run the ruby command prompt in the start menu with `ridk enable`.
- Update the start menu entry with the newly installed ruby version.
  They kept the old ruby version previously.
- Fix irb hook in ruby-3.1, which re-encodes `.irb_history` to UTF-8 on demand.
- Fix possible crash in `ridk use`. #291

### Removed
- No longer create registry keys under `Software\RubyInstaller\MRI\<RubyVersion>`. #242
  They weren't used any longer and didn't distinguish between 32 and 64-bit versions.
- No longer install the 32 bit but only the 64 bit version of MSYS2 as part of `ridk install`.
  It is still possible to get a pure 32-bit MSYS2 and Ruby installation by using the 32-bit RubyInstaller+Devkit package.
- The file `<ruby>\bin\ruby_builtin_dlls\libssp-0.dll` is no longer shipped as part of RubyInstaller.
  It is no longer needed with the latest gcc, but previously installed gems with extensions link to this DLL.
  The dependency to `libssp-0.dll` is currently still fulfilled by the bundled MSYS2 distribution.
  To re-compile the gem without this DLL `gem pristine --extensions` can be used.


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
