## RubyInstaller-3.0.7-1 - 2024-04-23

### Changed
- Update to ruby-3.0.7, see [release notes](https://www.ruby-lang.org/en/news/2024/04/23/ruby-3-0-7-released/).
- Update the SSL CA certificate list.
- Update to OpenSSL-1.1.1w and because version 1.1.1 is out of maintanence from the OpenSSL project apply all security patches that Canonical provides for Ubuntu-20.04:
  - CVE-2023-5678
  - CVE-2024-0727
  - Implicit rejection as a protection against Bleichenbacher attacks
- Update the bundled MSYS2 keyring package.


## RubyInstaller-3.0.6-1 - 2023-04-01

### Changed
- Update to ruby-3.0.6, see [release notes](https://www.ruby-lang.org/en/news/2023/03/30/ruby-3-0-6-released/).
- Update the SSL CA certificate list and to OpenSSL-1.1.1t.
- Add installer dialog to select per-user or all-users installation.
  See out Wiki for further [description of the install modes](https://github.com/oneclick/rubyinstaller2/wiki/FAQ#user-content-install-mode).
- Add installer options /ALLUSERS and /CURRENTUSER for silent install.
  For silent install see: https://github.com/oneclick/rubyinstaller2/wiki/FAQ#user-content-silent-install
- Enable automatic private gem installation in user's home on a machine wide ruby setup, if the user doesn't have write access.
- List machine wide rubies in addition to per-user rubies at `ridk use`.
- Set proper permissions of MSYS /tmp directory, so that every user can create and use files, but not read or change files of other users.
  This is needed for a machine wide installation.
- Check or add a system wide gemrc file at every rubygems load to prevent hijacking by another user.
- Avoid UNICODE characters in TMP env var to work around issues of gcc. #320


## RubyInstaller-3.0.5-1 - 2022-11-27

### Added
- Restrict write permissions to the installing user.
  For several reasons we use `C:/RubyXXX` direcory by default but not `C:/Program Files` (see: oneclick/rubyinstaller#135 ).
  Using an install path under `C:/` previously inherited write permissions for everyone, which compromised security in a multi user environment.
- `ridk use` Add options to store the change permanently in the user or system environment variables. #314

### Changed
- Update to ruby-3.0.5, see [release notes](https://www.ruby-lang.org/en/news/2022/11/24/ruby-3-0-5-released/).
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
- The file `<ruby>\bin\ruby_builtin_dlls\libssp-0.dll` is no longer shipped as part of RubyInstaller.
  It is no longer needed with the latest gcc, but previously installed gems with extensions link to this DLL.
  The dependency to `libssp-0.dll` is currently still fulfilled by the bundled MSYS2 distribution.
  To re-compile the gem without this DLL `gem pristine --extensions` can be used.


## RubyInstaller-3.0.4-1 - 2022-04-19

### Changed
- Update to ruby-3.0.4, see [release notes](https://www.ruby-lang.org/en/news/2022/04/12/ruby-3-0-4-released/).
- Update of the SSL CA certificate list.
- No longer require fiddle before booting Rubygems, but use the new C-extension "win32/dll_directory".
  Fixes #251
- Update the bundled MSYS2 keyring package.

### Removed
- No longer respond to MSYSTEM environment variable for setting a cross build environment. #269


## RubyInstaller-3.0.3-1 - 2021-11-27

### Added
- Allow setting a particular ridk/MSYS2 environment.
  It's described in the wiki: https://github.com/oneclick/rubyinstaller2/wiki/The-ridk-tool#ridk-enable--disable

### Changed
- Update to ruby-3.0.3, see [release notes](https://www.ruby-lang.org/en/news/2021/11/24/ruby-3-0-3-released/).
- Update of the SSL CA certificate list.


## RubyInstaller-3.0.2-1 - 2021-07-09

### Added
- Enable ruby to support path length >260 characters.
  See https://github.com/oneclick/rubyinstaller2/commit/829ab9d9798d180655b6b336797b1087bfa82f5c
- Add `racc`, `rbs` and `typeprof` to executables. #231

### Changed
- Update to ruby-3.0.2, see [release notes](https://www.ruby-lang.org/en/news/2021/07/07/ruby-3-0-2-released/).
- Update of the SSL CA certificate list.
- Move CI and and release builds from Appveyor to Github Actions.
- Move RunInstaller's pacman repository from Bintray to Github Releases.
- Update bundled gpg keyring file for pacman to support new MSYS2 package signatures.


## RubyInstaller-3.0.1-1 - 2021-04-19

### Added
- Add more environment variables needed for configure scripts: MSYSTEM_PREFIX, MSYSTEM_CARCH, MSYSTEM_CHOST, MINGW_CHOST, MINGW_PREFIX

### Changed
- Update to ruby-3.0.1, see [release notes](https://www.ruby-lang.org/en/news/2021/04/05/ruby-3-0-1-released/).
- Update to OpenSSL-1.1.1k .
- Update of the SSL CA certificate list.
- ridk version: Avoid possible crash due to invalid encoding. #208
- Install pkgconf instead of pkg-config on x86_64 following the change of MSYS2.
- Avoid creation of .irbrc if directory isn't writeable. #212
- Update the pacman repos in part 2 in addition to part 1. #220


## RubyInstaller-3.0.0-1 - 2020-12-28

This is the first release based on ruby-3.0.0: https://www.ruby-lang.org/en/news/2020/12/25/ruby-3-0-0-released/

### Changes compared to RubyInstaller-2.7.2-1
- `Encoding.default_encoding` and filesystem encoding is now UTF-8.
  The UTF-8 option is removed from the installer.
  Legacy console encoding can still be set manually per `RUBYOPT=-Elocale`.
