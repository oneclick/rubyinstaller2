## RubyInstaller-4.0.1-1 - 2026-01-16

### Added
- Add the missing `rdbg` executable. #474

### Changed
- Update to ruby-4.0.1, see [release notes](https://www.ruby-lang.org/en/news/2026/01/13/ruby-4-0-1-released/).
- Compact ENV display when `ridk enable`. #470
- Fix possible crash in `ridk enable` when searching the Windows registry.
- Check and add directory `etc/ssl/certs` in `c_rehash.rb`. #472
- Improve startmenu introduced in Ruby-4.0:
  - Various optical and behaviour improvements. #469
  - Add mouse event handling to classic terminal and avoid threads. #475
  - Return to startmenu from irb and ridk
- Preliminary support for MSYS2 environment `clang64` . #471
- Update links to point to the correct repository. #463

### Removed
- Remove libgcc_s_seh-1.dll. It is no longer necessary. #467


## RubyInstaller-4.0.0-1 - 2025-12-27

This is the first release based on ruby-4.0.x: https://www.ruby-lang.org/en/news/2025/12/25/ruby-4-0-0-released/

### Changes compared to [RubyInstaller-3.4.8-1](CHANGELOG-3.4.md#rubyinstaller-348-1---2025-12-18)

- Shrink the 5 app icons to only one and a subsequent console-based startmenu.
  One icon only is a requirement of Microsoft to provide an app in the Microsoft Store.
- Add a patch to fix ruby's CLI to recognize inputs as UTF-8
  https://github.com/ruby/ruby/pull/12377
- Drop X86/32-bit release package. Only X64 and ARM64 packages are provided for Ruby-4.0+.
