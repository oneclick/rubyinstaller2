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
