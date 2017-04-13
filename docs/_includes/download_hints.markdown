### Which version to download?

If you don’t know what version to install and you’re getting started with Ruby,
we recommend you use Ruby <b>2.2.X</b> installers. These provide a stable
language and a extensive list of packages (gems) that are compatible and
updated.

However, not all packages (gems) are maintained. Some older packages may not
be compatible with newer versions of Ruby and RubyInstaller.

The 64-bit versions of Ruby are relatively new on the Windows
area and not all the packages have been updated to be compatible with it.
To use this version you will require some knowledge about compilers and
solving dependency issues, which might be too complicated if you just want to
play with the language.

Users of CPUs older than Intel’s Nocona (90nm Pentium 4) who wish to use
Ruby 2.0.0 will need to build their own using a different DevKit by following these <a href="https://github.com/oneclick/rubyinstaller/wiki/Development-Kit#building-the-devkit">instructions</a>.

### Which Development Kit?


Down this page, several and <em>different</em> versions of Development Kits (DevKit) are listed. Please download the right one for your version of Ruby:

* Ruby 1.8.6 to 1.9.3: *tdm-32-4.5.2*
* Ruby 2.0.0 and above (32bits): *mingw64-32-4.7.2*
* Ruby 2.0.0 and above x64 (64bits): *mingw64-64-4.7.2*


### Download Issues?


Depending on your location, sometimes the downloads will not work. This is due RubyForge provided mirrors. Until we completely move our releases out of them. please add <strong>/noredirect</strong> at the end of the URL and try again.

Sorry the inconvenience.

### Speed and Compatibility


RubyInstaller is compiled with MinGW which offers improved speed and better
RubyGem compatibility, including support for many more native C-based extensions such as <a href="http://github.com/ffi/ffi">Ruby FFI</a>, <a href="http://nokogiri.org/">Nokogiri</a>,
<a href="http://www.fxruby.org/">FXRuby</a> and <a href="http://github.com/oneclick/rubyinstaller/wiki/Gem-List">many others</a>.

### Convenience


No additional software is needed if you want to use the executable versions of the RubyInstaller. If you would like
to use the 7-Zip archived versions or the Ruby documentation, you will need to download 7-Zip from
the [7-Zip website](http://www.7-zip.org/).

### Documentation


As an added convenience for Windows users, we’ve made available the Ruby Core and Standard Library documentation
in Compiled HTML Help (CHM) format.

### Build Your Own Native Extensions


The [RubyInstaller Development Kit (DevKit)](http://github.com/oneclick/rubyinstaller/wiki/Development-Kit) is
a MSYS/MinGW based toolkit than enables you to build many of the native C/C++ extensions available
for Ruby.

### Support


Enjoy, happy Ruby coding, and let us know what you think or if you have any issues at our helpful and friendly
[RubyInstaller Google Group](http://groups.google.com/group/rubyinstaller).

