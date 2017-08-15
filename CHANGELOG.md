## RubyInstaller-2.4.1-3pre1 - YYYY-MM-DD

### Added
- Sign published files per PGP signature.
- Set `LANG` variable in `ridk enable` because some MSYS apps require a valid setting.
  This also enables message translation of gettext enabled apps.
- Add stdlib gem "dbm", which was missing in previous RI2 versions.
- Add OS name and version to `ridk version`.

### Changed
- Upload signed files directly from Appveyor to Github for releases.
- Update of the SSL CA certificate list.

### Removed
- Remove deprecated `RubyInstaller.add_dll_directory`.


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
