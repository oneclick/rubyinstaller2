---
layout: post
title:  "RubyInstaller-2.4.1-1 released"
date:   2017-04-12 19:16:07 +0200
author: Lars Kanis
---
RubyInstaller-2.4 for Windows has been finally released!

It is based on the [MSYS2](https://msys2.org/) [toolchain](https://github.com/Alexpux/MINGW-packages) now, and the build scripts are rewritten from the scratch.
Therefore the github repository has changed - it is now [RubyInstaller2](https://github.com/oneclick/rubyinstaller2).

RubyInstaller2 brings some significant changes in addition to the newer Ruby version.
The most important change is that the DevKit is no longer provided.
Instead RubyInstaller makes use of the [MSYS2](https://msys2.org/) environment for compilation of C-based gems.
This and more changes are documented in the [CHANGELOG](https://github.com/oneclick/rubyinstaller2/blob/master/CHANGELOG.md).

RubyInstaller2 will be the base for Ruby versions 2.4.x and up. Ruby versions before 2.4 are based on [RubyInstaller1](https://github.com/oneclick/rubyinstaller) which is still [looking for a maintainer](https://github.com/oneclick/rubyinstaller/issues/348).

Please note, that many fat binary gems are not yet prepared for RubyInstaller-2.4. Try to use
```sh
gem install --platform ruby <gemname>
```
to force installation of the source gem, for the time being.
This requires MSYS2 and MINGW tools to be installed, for example per `ridk install`.
Also see the [FAQ](https://github.com/oneclick/rubyinstaller2/wiki/FAQ) for further recommendations.

Gem authors, who want to support RubyInstaller2, please refer to the [Tips for gem developers](https://github.com/oneclick/rubyinstaller2/wiki/For-gem-developers).
