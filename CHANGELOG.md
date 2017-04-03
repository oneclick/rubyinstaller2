## [rubyinstaller-2.4.1-1rc1] - 2017-03-31
The following notable changed are for the transition from [RubyInstaller1](https://github.com/oneclick/rubyinstaller) to [RubyInstaller2](https://github.com/oneclick/rubyinstaller2)

### Added
- Provides `ridk` tool for easy MSYS2 installation/usage and system version information.
- RubyInstaller2 bundles it's own SSL/TLS CA list derived from the current Mozilla CA list into `<installpath>/ssl/`. See [SSL-README](https://github.com/larskanis/rubyinstaller2/blob/master/resources/ssl/README-SSL.md).
- Create a default `.irbrc` file for tab completition and history in irb.
- Ability to add use rubyinstaller-build.gem for customized Ruby-Applications. Documentation comming soon...
- Run CI tests on appveyor for each git commit.
- Build and deploy rubyinstaller.exe and 7z packages per appveyor and github releases.

### Changed
- Built with MINGW gcc-6.3 from the [MSYS2 repository](https://github.com/Alexpux/MINGW-packages).
- Update to ruby-2.4.1 and update of bundled libraries/DLLs.
- `Encoding.default_external` is now `UTF-8` (no longer ancient `cpXYZ` encoding when reading files).
- RubyInstaller2 uses a separate DLL directory to avoid conflicting DLLs in the PATH.
- RubyInstaller2 uses a DLL loading mechanism which ignores the `PATH` environment variable for DLL lookups, but provides a API for DLL directory addition.
- Use pure HTML for ruby core+stdlib documentation instead of CHM files.
- Add ruby to the `PATH` and as `.rb` + `.rbw` file association per default.
- New versioning scheme: `rubyinstaller-<rubyver>-<pkgrel>-<arch>.exe` with `pkgrel` counting from 1 per `rubyver`.

### Removed
- No devkit anymore, but integrates with MSYS2 libraries and toolchain.
