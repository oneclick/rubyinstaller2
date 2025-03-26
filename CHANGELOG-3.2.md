## RubyInstaller-3.2.8-1 - 2025-03-26

### Changed
- Update to ruby-3.2.8, see [release notes](https://www.ruby-lang.org/en/news/2025/03/26/ruby-3-2-8-released/).


## RubyInstaller-3.2.7-1 - 2025-02-05

### Changed
- Update to ruby-3.2.7, see [release notes](https://www.ruby-lang.org/en/news/2025/02/04/ruby-3-2-7-released/).
- Fix automatic pacman package install when using bundler-2.5.x. [#396](https://github.com/oneclick/rubyinstaller2/issues/396)
- Fix pacman install error in parallel `bundler install -jX`. [#403](https://github.com/oneclick/rubyinstaller2/issues/403)
  `pacman` invocation is now serialized to avoid locking errors.
- Update MSYS2 download version to 2024-12-08 for `ridk install 1`. [#402](https://github.com/oneclick/rubyinstaller2/issues/402)
- Add junction (directory link) at `<ruby>/ssl`, which allows to easily find the OpenSSL certificates directory. [#399](https://github.com/oneclick/rubyinstaller2/issues/399)
  The certificates directory varies between ruby versions and the junction unifies the location.
  It is described in `<ruby>/ssl/README-SSL.md`.
- Update the SSL CA certificate list.
- Remove installed gems and MSYS2 by the uninstaller per default. [#408](https://github.com/oneclick/rubyinstaller2/issues/408)
  So far the uninstaller only removed the ruby install files, but kept installed gems and MSYS2.
  The old behaviour is available when running the uninstaller with option `/allfiles=no`.
  See in [the wiki](https://github.com/oneclick/rubyinstaller2/wiki/FAQ#user-content-silent-install).
  This is to prepare RubyInstaller for the Microsoft Store.


## RubyInstaller-3.2.6-1 - 2024-10-31

### Changed
- Update to ruby-3.2.6, see [release notes](https://www.ruby-lang.org/en/news/2024/10/30/ruby-3-2-6-released/).
- Update the SSL CA certificate list.
- Update to OpenSSL-3.4.0. The Ruby API dosn't change.
- Avoid early load of etc.so allowing updates of etc.gem. [#388](https://github.com/oneclick/rubyinstaller2/issues/388)
- Set a single key in gemrc to allow appending to this file. [#388](https://github.com/oneclick/rubyinstaller2/issues/388#issuecomment-2348393612)


## RubyInstaller-3.2.5-1 - 2024-07-26

### Changed
- Update to ruby-3.2.5, see [release notes](https://www.ruby-lang.org/en/news/2024/07/26/ruby-3-2-5-released/).
- Update the SSL CA certificate list.
- Update to OpenSSL-3.3.1. The Ruby API dosn't change.
- Update to InnoSetup-6.3.1 and OpenSSL-3.3.1


## RubyInstaller-3.2.4-1 - 2024-04-24

### Changed
- Update to ruby-3.2.4, see [release notes](https://www.ruby-lang.org/en/news/2024/04/23/ruby-3-2-4-released/).
- Update the SSL CA certificate list.
- Update to OpenSSL-3.3.0. The Ruby API dosn't change.
- Move bundled OpenSSL related files to bin/lib subdirectory so that legacy algorithms can be loaded through provider support. #365
- Update the bundled MSYS2 keyring package.
- Avoid crash even if a registry key incldues inconvertible characters
- Avoid method redefinition warning in rubygems hook


## RubyInstaller-3.2.3-1 - 2024-01-25

### Changed
- Update to ruby-3.2.3, see [release notes](https://www.ruby-lang.org/en/news/2024/01/18/ruby-3-2-3-released/).
- Update to OpenSSL-3.2.0.
  The Ruby API dosn't change.
- Update the SSL CA certificate list
- Allow setting of MSYS2 path by environment variable `MSYS2_PATH`. [#361](https://github.com/oneclick/rubyinstaller2/issues/361)
  This setting is preferred over all other methods to find the MSYS2 directory.
- Return registry strings as UTF-8 instead of OEM charset. [#348](https://github.com/oneclick/rubyinstaller2/issues/348)


## RubyInstaller-3.2.2-1 - 2023-04-01

### Changed
- Update to ruby-3.2.2, see [release notes](https://www.ruby-lang.org/en/news/2023/03/30/ruby-3-2-2-released/).
- Update to OpenSSL-3.1.0.
  The Ruby API dosn't change.
- Move OpenSSL config directroy from `<install-path>/etc/ssl/` to  `<install-path>/bin/etc/ssl/` to follow upstream change in MSYS2. [#337](https://github.com/oneclick/rubyinstaller2/issues/337)


## RubyInstaller-3.2.1-1 - 2023-02-09

### Changed
- Update to ruby-3.2.1, see [release notes](https://www.ruby-lang.org/en/news/2023/02/08/ruby-3-2-1-released/).
- Update the SSL CA certificate list and to OpenSSL-3.0.8.
- Move OpenSSL config directroy from `<install-path>/ssl/` to  `<install-path>/etc/ssl/` to follow upstream change in https://github.com/msys2/MINGW-packages/commit/2f97826e8a8fce0b9a49da7ea2bffbab7ce98eb5
- Allow home directory with white space when installing gems into users home. [#332](https://github.com/oneclick/rubyinstaller2/issues/332)
- Don't overwrite GEM_HOME or BUNDLE_SYSTEM_BINDIR if already present.
- Don't set bindir to a non-existing directory.
  This is related to https://github.com/rubygems/rubygems/issues/6332


## RubyInstaller-3.2.0-1 - 2022-12-29

This is the first release based on ruby-3.2.0: https://www.ruby-lang.org/en/news/2022/12/25/ruby-3-2-0-released/

### Changes compared to [RubyInstaller-3.1.3-1](CHANGELOG-3.1.md#rubyinstaller-313-1---2022-11-27)
- Add installer dialog to select per-user or all-users installation.
  See out Wiki for further [description of the install modes](https://github.com/oneclick/rubyinstaller2/wiki/FAQ#user-content-install-mode).
- Add installer options /ALLUSERS and /CURRENTUSER for silent install.
  For silent install see: https://github.com/oneclick/rubyinstaller2/wiki/FAQ#user-content-silent-install
- Enable automatic private gem installation in user's home on a machine wide ruby setup, if the user doesn't have write access.
- List machine wide rubies in addition to per-user rubies at `ridk use`.
- Add full administrator access to the install directory.
  Without this permission an admin had to use the `takeown` command to regain write access to a per-user installation.
- Set proper permissions of MSYS /tmp directory, so that every user can create and use files, but not read or change files of other users.
  This is needed for a machine wide installation.
- Check or add a system wide gemrc file at every rubygems load to prevent hijacking by another user.
- Avoid UNICODE characters in TMP env var to work around issues of gcc. [#320](https://github.com/oneclick/rubyinstaller2/issues/320)
- Switch to OpenSSL-3. This has several implications on the Ruby API and disables support for legacy crypto algorithms.
  See https://github.com/ruby/openssl/blob/master/History.md#version-300 and https://github.com/openssl/openssl/blob/master/doc/man7/migration_guide.pod#openssl-30
