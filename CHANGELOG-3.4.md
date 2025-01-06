## RubyInstaller-3.4.1-1 - 2024-12-30

This is the first release based on ruby-3.4.x: https://www.ruby-lang.org/en/news/2024/12/25/ruby-3-4-0-released/

### Changes compared to [RubyInstaller-3.3.6-2](CHANGELOG-3.2.md#rubyinstaller-326-1---2024-10-31)

- Fix installation of dependencies per `pacman` within a parallel `bundler install -jX` [#403](https://github.com/oneclick/rubyinstaller2/issues/403)
- Fix MSYS2_VERSION to use latest version master [#402](https://github.com/oneclick/rubyinstaller2/issues/402)
- Update the SSL CA certificate list and to OpenSSL-3.4.0.
