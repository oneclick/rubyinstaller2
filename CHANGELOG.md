## RubyInstaller-2.4.1-1rc2 - unreleased

### Added
- Allow MSYS2 to be shipped together with Ruby, independent from the install path.

### Changed
- Removed some unecessary DLLs previously shipped with the installer.
- Decrease the number of MSYS2 packages installed per default using 'ridk install'.


## RubyInstaller-2.4.1-1rc1 - 2017-03-31

The following notable changes are for the transition from [RubyInstaller1](https://github.com/oneclick/rubyinstaller) to [RubyInstaller2](https://github.com/oneclick/rubyinstaller2)

### Added
- Provides `ridk` tool for easy MSYS2 installation/usage and system version information.
- RubyInstaller2 bundles its own SSL/TLS CA list derived from the current Mozilla CA list into `<installpath>/ssl/`. See [SSL-README](https://github.com/larskanis/rubyinstaller2/blob/master/resources/ssl/README-SSL.md).
- Create a default `.irbrc` file for tab completition and history in irb.
- Ability to add and use `rubyinstaller-build.gem` for customized Ruby-Applications. Documentation coming soon...
- Run CI tests on AppVeyor for each `git push` to repository.
- Build and deploy `rubyinstaller.exe` and `7z` packages per AppVeyor and GitHub releases.

### Changed
- Built with MINGW GCC-6.3 from the [MSYS2 repository](https://github.com/Alexpux/MINGW-packages).
- Updated to Ruby-2.4.1.
- Updated bundled libraries/DLLs.
- `Encoding.default_external` is now `UTF-8` &mdash; no longer ancient `cpXYZ` encoding when reading files.
- RubyInstaller2 uses a separate DLL directory to avoid conflicting DLLs in the PATH.
- RubyInstaller2 uses a DLL loading mechanism which ignores the `PATH` environment variable for DLL lookups, but provides a API for DLL directory-addition.
- Use pure HTML for `Ruby Core + stdlib` documentation instead of CHM files.
- Add Ruby to the `PATH` and have `.rb` + `.rbw` file association by default.
- New versioning scheme: `rubyinstaller-<rubyver>-<pkgrel>-<arch>.exe` with `pkgrel` counting from 1 per `rubyver`.

### Removed
- No more DevKit, but integrates with MSYS2 libraries and toolchain.
