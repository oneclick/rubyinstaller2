## RubyInstaller-3.4.7-1 - 2025-10-08

### Changed
- Update to ruby-3.4.7, see [release notes](https://www.ruby-lang.org/en/news/2025/10/07/ruby-3-4-7-released/).


## RubyInstaller-3.4.6-1 - 2025-09-18

### Changed
- Update to ruby-3.4.6, see [release notes](https://www.ruby-lang.org/en/news/2025/09/16/ruby-3-4-6-released/).


## RubyInstaller-3.4.5-1 - 2025-07-25

### Changed
- Update to ruby-3.4.5, see [release notes](https://www.ruby-lang.org/en/news/2025/07/15/ruby-3-4-5-released/).
- Update the SSL CA certificate list.


## RubyInstaller-3.4.4-2 - 2025-05-18

### Changed
- Fix issue with `-std=c99` which broke install of some gems. [439](https://github.com/oneclick/rubyinstaller2/issues/439)


## RubyInstaller-3.4.4-1 - 2025-05-16

### Added
- Add `libwinpthread-1.dll` as dependecy of `date_core.so` on all architectures and as a general dependency of ruby on ARM64. [#434](https://github.com/oneclick/rubyinstaller2/issues/434), [ruby/date#126](https://github.com/ruby/date/issues/126)

### Changed
- Update to ruby-3.4.4, see [release notes](https://www.ruby-lang.org/en/news/2025/05/14/ruby-3-4-4-released/).
- Update the SSL CA certificate list.
- Update devkit version to gcc-15.1.


## RubyInstaller-3.4.3-1 - 2025-04-15

### Changed
- Update to ruby-3.4.3, see [release notes](https://www.ruby-lang.org/en/news/2025/04/14/ruby-3-4-3-released/).
- Update to OpenSSL-3.5.0. The Ruby API dosn't change.


## RubyInstaller-3.4.2-1 - 2025-02-15

### Changed
- Update to ruby-3.4.2, see [release notes](https://www.ruby-lang.org/en/news/2025/02/14/ruby-3-4-2-released/).
- Update the SSL CA certificate list.
- Update to OpenSSL-3.4.1. The Ruby API dosn't change.


## RubyInstaller-3.4.1-2 - 2025-01-18

### Added

- Add a native ARM64 version. [#362](https://github.com/oneclick/rubyinstaller2/issues/362)
- Add junction (directory link) at `<ruby>/ssl`, which allows to easily find the OpenSSL certificates directory. [#399](https://github.com/oneclick/rubyinstaller2/issues/399)
  The certificates directory varies between ruby versions and the junction unifies the location.
  It is described in `<ruby>/ssl/README-SSL.md`.

### Changed

- Change side-by-side DLL loading to store dependencies in each extension.so file. [#60](https://github.com/oneclick/rubyinstaller2/issues/60)
- Change the OpenSSL certificates directory to `<ruby>/lib/ruby/<ruby-version>/etc/ssl`.
- Remove installed gems and MSYS2 by the uninstaller per default. [#408](https://github.com/oneclick/rubyinstaller2/issues/408)
  So far the uninstaller only removed the ruby install files, but kept installed gems and MSYS2.
  The old behaviour is available when running the uninstaller with option `/allfiles=no`.
  See in [the wiki](https://github.com/oneclick/rubyinstaller2/wiki/FAQ#user-content-silent-install).
  This is to prepare RubyInstaller for the Microsoft Store.


## RubyInstaller-3.4.1-1 - 2024-12-30

This is the first release based on ruby-3.4.x: https://www.ruby-lang.org/en/news/2024/12/25/ruby-3-4-0-released/

### Changes compared to [RubyInstaller-3.3.6-2](CHANGELOG-3.2.md#rubyinstaller-326-1---2024-10-31)

- Fix installation of dependencies per `pacman` within a parallel `bundler install -jX` [#403](https://github.com/oneclick/rubyinstaller2/issues/403)
- Fix MSYS2_VERSION to use latest version master [#402](https://github.com/oneclick/rubyinstaller2/issues/402)
- Update the SSL CA certificate list and to OpenSSL-3.4.0.
