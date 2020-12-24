## RubyInstaller-3.0.0-1 - 2020-12-26

This is the first release based on ruby-3.0.0: https://www.ruby-lang.org/en/news/2020/12/25/ruby-3-0-0-released/

### Changes compared to RubyInstaller-2.7.2-1
- UTF-8 encoding is now enabled for `Encoding.default_encoding` and filesystem encoding instead of the console encoding.
  The UTF-8 option is removed from the installer.
  Legacy console encoding can still be set per `RUBYOPT=-Elocale`.
