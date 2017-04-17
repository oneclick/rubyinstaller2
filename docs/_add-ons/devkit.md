---
layout: add-on
titel:  "MSYS2 / DevKit"
order: 20
---
## Meet MSYS and the DevKit

Sometimes you just want RubyGems to build that cool native, C-based extension without squawking.
Who’s your buddy?
The DevKit that’s who!

### MSYS2-DevKit (only Ruby >= 2.4)
Stating with RubyInstaller-2.4 we're no longer using our own DevKit compilation, but make use of MSYS2 for both, building ruby itself, as well as building Ruby gems with C-extensions.
It can be installed per `ridk install` command, which is part of RubyInstaller-2.4. Alternatively a manual download and installation from [MSYS2](http://www.msys2.org) is also possible.

### Dedicated DevKit (only Ruby < 2.4)

The [RubyInstaller Development Kit](http://rubyinstaller.org/downloads/) is a toolkit that makes it easy to build and use native C/C++ extensions such as RDiscount and Nokogiri for Ruby on Windows.
It is built upon MSYS1, which is no longer maintained, now.
So you should upgrade to RubyInstaller-2.4 with makes use of MSYS2.

Simply download, double-click, choose an installation directory, run the Ruby install helper script and you’re ready to start using native Ruby extensions.
For installation details check out the [Development Kit wiki page](http://github.com/oneclick/rubyinstaller/wiki/Development-Kit).
