## RubyInstaller-3.3.10-1 - 2025-10-24

### Changed
- Update to ruby-3.3.10, see [release notes](https://www.ruby-lang.org/en/news/2025/10/23/ruby-3-3-10-released/).
- Update the SSL CA certificate list.


## RubyInstaller-3.3.9-1 - 2025-07-25

### Changed
- Update to ruby-3.3.9, see [release notes](https://www.ruby-lang.org/en/news/2025/07/24/ruby-3-3-9-released/).
- Update to OpenSSL-3.5.1. The Ruby API dosn't change.
- Update devkit version to gcc-15.1 which has some incompatibilities due to changed defaults.
- Update the SSL CA certificate list.
- Fix issue with `-std=c99` which broke install of some gems. [439](https://github.com/oneclick/rubyinstaller2/issues/439)


## RubyInstaller-3.3.8-1 - 2025-04-10

### Changed
- Update to ruby-3.3.8, see [release notes](https://www.ruby-lang.org/en/news/2025/04/09/ruby-3-3-8-released/).
- Update the SSL CA certificate list.


## RubyInstaller-3.3.7-1 - 2025-01-18

### Changed
- Remove installed gems and MSYS2 by the uninstaller per default. [#408](https://github.com/oneclick/rubyinstaller2/issues/408)
  So far the uninstaller only removed the ruby install files, but kept installed gems and MSYS2.
  The old behaviour is available when running the uninstaller with option `/allfiles=no`.
  See in [the wiki](https://github.com/oneclick/rubyinstaller2/wiki/FAQ#user-content-silent-install).
  This is to prepare RubyInstaller for the Microsoft Store.
- Fix pacman install error in parallel `bundler install -jX`. [#403](https://github.com/oneclick/rubyinstaller2/issues/403)
  `pacman` invocation is now serialized to avoid locking errors.
- Add junction (directory link) at `<ruby>/ssl`, which allows to easily find the OpenSSL certificates directory. [#399](https://github.com/oneclick/rubyinstaller2/issues/399)
  The certificates directory varies between ruby versions and the junction unifies the location.
  It is described in `<ruby>/ssl/README-SSL.md`.
- Update MSYS2 download version to 2024-12-08 for `ridk install 1`. [#402](https://github.com/oneclick/rubyinstaller2/issues/402)
- Update the SSL CA certificate list.


## RubyInstaller-3.3.6-2 - 2024-11-09

### Changed
- [Fix regression](https://github.com/oneclick/rubyinstaller2/commit/978e145d89b51c671c4f4cab07ebfabe0ac158c8) of handling command line arguments with characters outside of the current code page.
  In this case RubyInstaller-3.3.6-1 failed with:
  `command line contains characters that are not supported in the active code page`
  Fixes [bundler#8221](https://github.com/rubygems/rubygems/pull/8221)
- Fix automatic pacman package install when using bundler-2.5.x. [#396](https://github.com/oneclick/rubyinstaller2/issues/396)


## RubyInstaller-3.3.6-1 - 2024-11-07

### Changed
- Update to ruby-3.3.6, see [release notes](https://www.ruby-lang.org/en/news/2024/11/05/ruby-3-3-6-released/).
- Update the SSL CA certificate list.
- Update to OpenSSL-3.4.0. The Ruby API dosn't change.
- Avoid early load of etc.so allowing updates of etc.gem. [#388](https://github.com/oneclick/rubyinstaller2/issues/388)
- Set a single key in gemrc to allow appending to this file. [#388](https://github.com/oneclick/rubyinstaller2/issues/388#issuecomment-2348393612)


## RubyInstaller-3.3.5-1 - 2024-09-05

### Changed
- Update to ruby-3.3.5, see [release notes](https://www.ruby-lang.org/en/news/2024/09/03/3-3-5-released/).


## RubyInstaller-3.3.4-1 - 2024-07-09

### Changed
- Update to ruby-3.3.4, see [release notes](https://www.ruby-lang.org/en/news/2024/07/09/ruby-3-3-4-released/).


## RubyInstaller-3.3.3-1 - 2024-06-14

### Changed
- Update to ruby-3.3.3, see [release notes](https://www.ruby-lang.org/en/news/2024/06/12/ruby-3-3-3-released/).
- Update to InnoSetup-6.3.1 and OpenSSL-3.3.1
- Update the SSL CA certificate list.


## RubyInstaller-3.3.2-1 - 2024-06-03

### Changed
- Update to ruby-3.3.2, see [release notes](https://www.ruby-lang.org/en/news/2024/05/30/ruby-3-3-2-released/).


## RubyInstaller-3.3.1-1 - 2024-04-24

### Changed
- Update to ruby-3.3.1, see [release notes](https://www.ruby-lang.org/en/news/2024/04/23/ruby-3-3-1-released/).
- Update the SSL CA certificate list.
- Update to OpenSSL-3.3.0. The Ruby API dosn't change.
- Move bundled OpenSSL related files to bin/lib subdirectory so that legacy algorithms can be loaded through provider support. #365
- Update the bundled MSYS2 keyring package.
- Avoid crash even if a registry key incldues inconvertible characters
- Avoid method redefinition warning in rubygems hook
- Allow setting of MSYS2 path by environment variable `MSYS2_PATH`. [#361](https://github.com/oneclick/rubyinstaller2/issues/361)
  This setting is preferred over all other methods to find the MSYS2 directory.


## RubyInstaller-3.3.0-1 - 2023-12-26

This is the first release based on ruby-3.3.0: https://www.ruby-lang.org/en/news/2023/12/25/ruby-3-3-0-released/

### Changes compared to [RubyInstaller-3.2.2-1](CHANGELOG-3.2.md#rubyinstaller-322-1---2023-04-01)

- Remove the `.irbrc` file previously generated by RubyInstaller versions before 3.3.0.
  It is no longer necessary, since the enabled extensions have been made defaults in ruby core.
- Return registry strings as UTF-8 instead of OEM charset. [#348](https://github.com/oneclick/rubyinstaller2/issues/348)
- Update the SSL CA certificate list and to OpenSSL-3.2.0.
