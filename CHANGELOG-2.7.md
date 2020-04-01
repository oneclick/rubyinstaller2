## RubyInstaller-2.7.1-1 - 2020-04-02

### Changed
- Update to ruby-2.7.1, see [release notes](https://www.ruby-lang.org/en/news/2020/03/31/ruby-2-7-1-released/).
- Update to OpenSSL-1.1.1f .
- Don't update MSYS/MINGW packages at `ridk install` per default. #168
- Show compiler version, used to build ruby in `ridk version`. #171


## RubyInstaller-2.7.0-1 - 2020-01-05

This is the first release based on ruby-2.7.0: https://www.ruby-lang.org/en/news/2019/12/25/ruby-2-7-0-released/

### Changes compared to RubyInstaller-2.6.5-1
- Replace rb-readline by new reline implementation.
  It has multiline editing, better support for UTF-8 encoding and many fixes.
- UTF-8 encoding is now enabled by default in the installer.
  This is done by setting RUBYOPT=-Eutf-8 and affects Encoding.default_encoding which is then "UTF-8" instead of the console encoding.
  See [core API](https://ruby-doc.org/core-2.7.0/Encoding.html#method-c-default_external) for more details.
  Using UTF-8 default encoding avoids inconsistencies between reading and writing files and to other operating systems.
- IRB history is rewritten to UTF-8 if UTF-8 encoding is enabled.
