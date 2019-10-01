## RubyInstaller-2.4.8-1 - 2019-10-02

### Changed
- Update to ruby-2.4.8, see [release notes](https://www.ruby-lang.org/en/news/2019/10/01/ruby-2-4-8-released/).
- Fix code signatures of installer executables. They were invalid at the 2.4.7-1 release.


## RubyInstaller-2.4.7-1 - 2019-09-09

### Added
- Add support for scoop installer. #152

### Changed
- Update to ruby-2.4.7, see [release notes](https://www.ruby-lang.org/en/news/2019/08/28/ruby-2-4-7-released/).
- Ignore registry entries with invalid installer data when looking for MSYS2. #154


## RubyInstaller-2.4.6-1 - 2019-04-13

### Changed
- Update to ruby-2.4.6, see [release notes](https://www.ruby-lang.org/en/news/2019/04/01/ruby-2-4-6-released/).
- Build with "-O3" instead of "-O2" optimization and update x64 compiler from gcc-8.2.1 to 8.3.0.
- New tool `ridk use` to switch between installed ruby versions
- Update of the SSL CA certificate list.


## RubyInstaller-2.4.5-1 - 2018-10-21

### Changed
- Installer files are signed with a Microsoft trusted certificate now.
- Strip debug information from compiled extensions.
  This significantly decreases install size of C based gems. #130
- Fix RubyInstaller update mechanism, so that it no longer removes the PATH setting. #125
- Update to OpenSSL-1.0.2p and libgdbm-1.18.
- Update of the SSL CA certificate list.


## RubyInstaller-2.4.4-2 - 2018-06-24

### Changed
- Update `ridk install` to download msys2 installer version 20180531. #115
- Fix MSYS2 detection in `ridk install`. This broke download of MSYS2 installer. #114
- Don't crash when the mingw directory within MSYS2 isn't present.
- Update of the SSL CA certificate list.


## RubyInstaller-2.4.4-1 - 2018-03-29

### Added
- New installer for Ruby with builtin MSYS2 Devkit toolchain. #42

### Changed
- Update to ruby-2.4.4, see [release notes](https://www.ruby-lang.org/en/news/2018/03/28/ruby-2-4-4-released/).
- Update to OpenSSL-1.0.2o .
- Make installers with/without Devkit compatible, so that both can be mixed like:
  - Install RubyInstaller-Devkit first and update with smaller RubyInstaller later
  - Install RubyInstaller first and update by RubyInstaller-Devkit


## RubyInstaller-2.4.3-2 - 2018-02-27

### Changed
- Don't abort but fix pacman conflicts while 'ridk install'. #101


## RubyInstaller-2.4.3-1 - 2017-12-20

### Changed
- Update to ruby-2.4.3, see [release notes](https://www.ruby-lang.org/en/news/2017/12/14/ruby-2-4-3-released/).
- Ignore invalid character encodings when scaning registry for MSYS2.
  [#86](https://github.com/oneclick/rubyinstaller2/issues/86)
- Update of the SSL CA certificate list.
- Uninstall old RubyInstaller version when doing update.
  It avoids broken and orphaned links in the startmenu
  [#78](https://github.com/oneclick/rubyinstaller2/issues/78#issuecomment-330115604).
  See also [updating RubyInstaller](https://github.com/oneclick/rubyinstaller2/wiki/FAQ#q-what-is-recommended-way-to-update-a-ruby-installation).

### Removed
- Remove package 'winstorecompat' from default dev tools, to make `ridk install` step 2 optional.
  [#88](https://github.com/oneclick/rubyinstaller2/issues/88)


## RubyInstaller-2.4.2-2 - 2017-09-15

### Changed
- Fix a regession of ruby-2.4.2 to not link to libgmp.
  See [ruby-2.4.2 release notes](https://www.ruby-lang.org/en/news/2017/09/14/ruby-2-4-2-released/) .


## RubyInstaller-2.4.2-1 - 2017-09-15

### Added
- Sign published files per PGP signature.
- Set `LANG` variable in `ridk enable` because some MSYS apps require a valid setting.
  This also enables message translation of gettext enabled apps.
- Add stdlib gem "dbm", which was missing in previous RI2 versions. #65
- Add OS name and version to `ridk version`.

### Changed
- Upload signed files directly from Appveyor to Github for releases.
- Update of the SSL CA certificate list.
- Fix gdbm open error by downgrading to gdbm-1.10. [#4](https://github.com/oneclick/rubyinstaller2-packages/pull/4)

### Removed
- Remove deprecated `RubyInstaller.add_dll_directory`.
- Remove superflous build flags for libffi from RbConfig. [#8](https://github.com/oneclick/rubyinstaller2-packages/pull/8)


## RubyInstaller-2.4.1-2 - 2017-07-04

### Added
- Add package called 'rubybundle' with embedded MSYS2 tree as preview.
- Add daily ruby-2.5 snapshot builds, downloadable from [Appveyor](https://ci.appveyor.com/project/larskanis/rubyinstaller2-hbuor/branch/master).
- Add possibility to set DLL paths per environment variable RUBY_DLL_PATH. Fixes #51
- Don't run 'ridk install' when installing with silent option. Fixes #43

### Changed
- Do full MSYS2 system update instead of inventory update only.
  Fixes possible library inconsistences on a partially updated system.
- Spin off compile task to https://github.com/oneclick/rubyinstaller2-packages to speedup packaging.
- Update of dependent DLLs and build tools to latest MSYS2 versions.
- Update of the SSL CA certificate list.


## RubyInstaller-2.4.1-1 - 2017-05-25

The following notable changes are for the transition from [RubyInstaller1](https://github.com/oneclick/rubyinstaller) to [RubyInstaller2](https://github.com/oneclick/rubyinstaller2)

### Added
- Provides `ridk` tool for easy MSYS2 installation/usage and system version information.
- RubyInstaller2 bundles its own SSL/TLS CA list derived from the current Mozilla CA list into `<installpath>/ssl/`. See [SSL-README](https://github.com/larskanis/rubyinstaller2/blob/master/resources/ssl/README-SSL.md).
- Create a default `.irbrc` file for tab completition and history in irb.
- Ability to add and use `rubyinstaller-build.gem` for customized Ruby-Applications. Documentation coming soon...
- Run CI tests on AppVeyor for each `git push` to repository.
- Build and deploy `rubyinstaller.exe` and `7z` packages per AppVeyor and GitHub releases.
- Allow MSYS2 to be shipped together with Ruby, when installed side by side or within the ruby directory.
  Refer to the [FAQ](https://github.com/oneclick/rubyinstaller2/wiki/FAQ#user-content-portable-install).
- Add an installer option to set `RUBYOPT=-Eutf-8`, which sets `Encoding.default_external` to `UTF-8`.

### Changed
- Built with MINGW GCC-6.3 from the [MSYS2 repository](https://github.com/Alexpux/MINGW-packages).
- Updated to Ruby-2.4.1.
- Updated bundled libraries/DLLs.
- RubyInstaller2 uses a separate DLL directory to avoid conflicting DLLs in the PATH.
- RubyInstaller2 uses a DLL loading mechanism which ignores the `PATH` environment variable for DLL lookups, but provides a API for DLL directory-addition.
- Use pure HTML for `Ruby Core + stdlib` documentation instead of CHM files.
- Add Ruby to the `PATH` and have `.rb` + `.rbw` file association by default.
- New versioning scheme: `rubyinstaller-<rubyver>-<pkgrel>-<arch>.exe` with `pkgrel` counting from 1 per `rubyver`.

### Removed
- No more DevKit, but integrates with MSYS2 libraries and toolchain.
- Remove `tk` from stdlibs, still available per `gem install tk`. This is a upstream change in ruby-2.4.
