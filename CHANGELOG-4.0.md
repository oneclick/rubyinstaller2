## RubyInstaller-4.0.0-1 - 2025-12-27

This is the first release based on ruby-4.0.x: https://www.ruby-lang.org/en/news/2025/12/25/ruby-4-0-0-released/

### Changes compared to [RubyInstaller-3.4.8-1](CHANGELOG-3.4.md#rubyinstaller-348-1---2025-12-18)

- Shrink the 5 app icons to only one and a subsequent console-based startmenu.
  One icon only is a requirement of Microsoft to provide an app in the Microsoft Store.
- Add a patch to fix ruby's CLI to recognize inputs as UTF-8
  https://github.com/ruby/ruby/pull/12377
