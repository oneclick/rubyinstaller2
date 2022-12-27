## RubyInstaller-3.2.0-1 - 2021-12-26

This is the first release based on ruby-3.2.0: https://www.ruby-lang.org/en/news/2022/12/25/ruby-3-2-0-released/

### Changes compared to RubyInstaller-3.1.3-1
- Add installer dialog to select per-user or all-users installation and add installer options /ALLUSERS and /CURRENTUSER for silent install.
  For silent install see: https://github.com/oneclick/rubyinstaller2/wiki/FAQ#user-content-silent-install
- Enable gem installation in user's home on a machine wide ruby setup.
- List machine wide rubies in addition to per-user rubies at `ridk use`.
- Add full administrator access to the install directory.
  Without this permission an admin had to use the `takeown` command to regain write access to a per-user installation.
- Check or add a system wide gemrc file at every rubygems load to prevent hijacking by another user.
- Avoid UNICODE characters in TMP env var to work around issues of gcc. #320
- Switch to OpenSSL-3. This has several implications on the Ruby API and disables support for legacy crypto algorithms.
  See https://github.com/ruby/openssl/blob/master/History.md#version-300 and https://github.com/openssl/openssl/blob/master/doc/man7/migration_guide.pod#openssl-30
