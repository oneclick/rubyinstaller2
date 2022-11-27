## RubyInstaller-2.7.7-1 - 2022-11-27

### Added
- Restrict write permissions to the installing user.
  For several reasons we use `C:/RubyXXX` direcory by default but not `C:/Program Files` (see: oneclick/rubyinstaller#135 ).
  Using an install path under `C:/` previously inherited write permissions for everyone, which compromised security in a multi user environment.
- `ridk use` Add options to store the change permanently in the user or system environment variables. #314

### Changed
- Update to ruby-3.0.5, see [release notes](https://www.ruby-lang.org/en/news/2022/11/24/ruby-2-7-7-released/).
- Update of the SSL CA certificate list.
- Update the bundled MSYS2 keyring package.
- Fix start menu entry for rubygems-server.
- Run the ruby command prompt in the start menu with `ridk enable`.
- Update the start menu entry with the newly installed ruby version.
  They kept the old ruby version previously.
- Fix possible crash in `ridk use`. #291

### Removed
- No longer create registry keys under `Software\RubyInstaller\MRI\<RubyVersion>`. #242
  They weren't used any longer and didn't distinguish between 32 and 64-bit versions.
- No longer install the 32 bit but only the 64 bit version of MSYS2 as part of `ridk install`.
  It is still possible to get a pure 32-bit MSYS2 and Ruby installation by using the 32-bit RubyInstaller+Devkit package.


## RubyInstaller-2.7.6-1 - 2022-04-19

### Changed
- Update to ruby-2.7.6, see [release notes](https://www.ruby-lang.org/en/news/2022/04/12/ruby-2-7-6-released/).
- Update of the SSL CA certificate list.
- No longer require fiddle before booting Rubygems, but use the new C-extension "win32/dll_directory".
  Fixes #251
- Update the bundled MSYS2 keyring package.

### Removed
- No longer respond to MSYSTEM environment variable for setting a cross build environment. #269


## RubyInstaller-2.7.5-1 - 2021-11-27

### Added
- Allow setting a particular ridk/MSYS2 environment.
  It's described in the wiki: https://github.com/oneclick/rubyinstaller2/wiki/The-ridk-tool#ridk-enable--disable

### Changed
- Update to ruby-2.7.5, see [release notes](https://www.ruby-lang.org/en/news/2021/11/24/ruby-2-7-5-released/).
- Update of the SSL CA certificate list.


## RubyInstaller-2.7.4-1 - 2021-07-09

### Added
- Enable ruby to support path length >260 characters.
  See https://github.com/oneclick/rubyinstaller2/commit/829ab9d9798d180655b6b336797b1087bfa82f5c
- Add `racc` to executables. #231

### Changed
- Update to ruby-2.7.4, see [release notes](https://www.ruby-lang.org/en/news/2021/07/07/ruby-2-7-4-released/).
- Update of the SSL CA certificate list.
- Move CI and and release builds from Appveyor to Github Actions.
- Move RunInstaller's pacman repository from Bintray to Github Releases.
- Update bundled gpg keyring file for pacman to support new MSYS2 package signatures.


## RubyInstaller-2.7.3-1 - 2021-04-19

### Added
- Add more environment variables needed for configure scripts: MSYSTEM_PREFIX, MSYSTEM_CARCH, MSYSTEM_CHOST, MINGW_CHOST, MINGW_PREFIX

### Changed
- Update to ruby-2.7.3, see [release notes](https://www.ruby-lang.org/en/news/2021/04/05/ruby-2-7-3-released/).
- Update to OpenSSL-1.1.1k .
- Update of the SSL CA certificate list.
- ridk version: Avoid possible crash due to invalid encoding. #208
- Install pkgconf instead of pkg-config on x86_64 following the change of MSYS2.
- Avoid creation of .irbrc if directory isn't writeable. #212
- Update the pacman repos in part 2 in addition to part 1. #220


## RubyInstaller-2.7.2-1 - 2020-10-06

### Added
- Add migration of new MSYS2 signature keys to "ridk install". #184, #182
- Add RDoc based RI documentation as an install option.
  It can be used per tab completion in irb.
- Add automake-1.16 package.
- Run autorebase.bat at installation on 32 bit x86 systems.
  This is required with more recent versions of msys32.
- Kill running MSYS2 processes for MSYS2 initialization and update.
  This avoids the error "size of shared memory region changed" when MSYS2 core DLLs are changed.
- `ridk use` improvements:
    - sorts the list of rubies
    - plays well together with `ridk enable` now
    - removes itself from PATH when returning to original ruby.

### Changed
- Move HTML documentation to optional install component "Ruby RI and HTML documentation".
- Update to OpenSSL-1.1.1g, libffi-3.3 and gcc-10.2.
- Update to InnoSetup-6 which enables a larger and resizable installer window.
- Skip gemspec based package install if dependency is already satisfied. #67
  This avoids unwanted/unnecessary up- or downgrades of MSYS2/MINGW packages on "gem install" when a package is already installed and the version meets optional version constraints.
- Update of the SSL CA certificate list.
- Fix a memory leak in DllDirectory.
- Fix vendoring issue of recent MSYS2 system.

### Removed
- Remove now unused Gem install helper.


## RubyInstaller-2.7.1-1 - 2020-04-02

### Changed
- Update to ruby-2.7.1, see [release notes](https://www.ruby-lang.org/en/news/2020/03/31/ruby-2-7-1-released/).
- Update to OpenSSL-1.1.1f .
- Don't update MSYS/MINGW packages at `ridk install` per default. #168
- Show compiler version, used to build ruby in `ridk version`. #171
- IRB history is rewritten to UTF-8 on first start of irb.


## RubyInstaller-2.7.0-1 - 2020-01-05

This is the first release based on ruby-2.7.0: https://www.ruby-lang.org/en/news/2019/12/25/ruby-2-7-0-released/

### Changes compared to RubyInstaller-2.6.5-1
- Replace rb-readline by new reline implementation.
  It has multiline editing, better support for UTF-8 encoding and many fixes.
- UTF-8 encoding is now enabled by default in the installer.
  This is done by setting RUBYOPT=-Eutf-8 and affects Encoding.default_encoding which is then "UTF-8" instead of the console encoding.
  See [core API](https://ruby-doc.org/core-2.7.0/Encoding.html#method-c-default_external) for more details.
  Using UTF-8 default encoding avoids inconsistencies between reading and writing files and to other operating systems.
- IRB history is rewritten to UTF-8 if UTF-8 encoding is enabled.
