#RubyInstaller2

This project provides an Installer for Ruby on Windows based on the MSYS2 toolchain.
It is licensed under the 3-clause Modified BSD License.

In contrast to the [RubyInstaller](https://github.com/oneclick/rubyinstaller/) it does not provide it's own DevKit, but makes use of the rich set of [MINGW libraries](https://github.com/Alexpux/MINGW-packages) of the [MSYS2 project](https://msys2.github.io/) .
It therefore integrates well into MSYS2 after installation on the target system to provide a build- and runtime environment for installation of gems with C-extensions.

This project is currently in a very early stage.
Testers and contributors are welcome.
The aim is to build a successor to the [RubyInstaller](https://github.com/oneclick/rubyinstaller/) .

## Using the Installer on a target system

- Download and install the latest RubyInstaller: https://github.com/larskanis/rubyinstaller2/releases

That's enough to use pure Ruby gems or fat binary gems for x64-mingw32 or x86-mingw32.
In order to build gems with C-extensions, install MSYS2 like so:

- Install the latest MSYS2 for x64 or x86 at the default path per installer: https://msys2.github.io/

- Run cmd.exe with the following commands:
```sh
    rubydevkit
    pacman -Sy pacman
    pacman -S base-devel mingw-w64-i686-toolchain # for 32 bit RubyInstaller
    pacman -S base-devel mingw-w64-x86_64-toolchain # for 64 bit RubyInstaller
    gem install your-gem --platform ruby
```

`rubydevkit` is a cmd script which sets environment variables to enable MSYS commands like `pacman` .
These are automatically set while `gem install` .

### Install gems with C-extensions and additional library dependencies

Installation of additional library dependencies can be done per pacman as well. Exchange `mingw-w64-x86_64` by `mingw-w64-i686` for the 32-bit RubyInstaller.
For instance:

- Install pg.gem
```sh
    rubydevkit
    pacman -S mingw-w64-x86_64-postgresql
    gem install pg --platform ruby
```

- Install sqlite3.gem
```sh
    rubydevkit
    pacman -S mingw-w64-x86_64-sqlite3
    gem install sqlite3 --platform ruby
```

- Install nokogiri.gem
```sh
    rubydevkit
    pacman -S mingw-w64-x86_64-libxslt
    gem install nokogiri --platform ruby -- --use-system-libraries --with-xml2-include=c:/msys64/mingw64/include/libxml2 --with-xslt-dir=c:/msys64/mingw64
```

The DLL search paths of Ruby processes are extended as soon as rubygems is used, so that MINGW DLLs are found at runtime.

## Build the Installer

- Make sure you have a working Ruby installation

- Install the latest MSYS2 for x64 at the default path per installer: https://msys2.github.io/

- Use MSYS shell to install the mingw64 toolchain:
```sh
    pacman -Sy pacman
    pacman -S base-devel  mingw-w64-x86_64-toolchain  mingw-w64-i686-toolchain
```

- Install the latest Inno-Setup (unicode): http://www.jrsoftware.org/isdl.php

- Run cmd.exe and add iscc.exe to PATH: ```set PATH=%PATH%;"c:\Program Files (x86)\Inno Setup 5"```

- Then compile and package Ruby:
```sh
    rake ruby-2.4.0-x64:installer  ruby-2.4.0-x86:installer
```

- If everything works well, you will find the final setup files `installer/rubyinstaller-2.4.0-1-x64.exe` and `installer/rubyinstaller-2.4.0-1-x64.exe`

##Known Issues

* Avoid running this project in a PATH containing spaces.
* See also [the issue list](https://github.com/larskanis/rubyinstaller2/issues)
