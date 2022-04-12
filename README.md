[![CI build status](https://github.com/oneclick/rubyinstaller2/actions/workflows/ci.yml/badge.svg)](https://github.com/oneclick/rubyinstaller2/actions/workflows/ci.yml)

# RubyInstaller2

This project provides an Installer for Ruby-2.4 and newer on Windows based on the MSYS2 toolchain.
It is the successor to the MSYS1 based [RubyInstaller](https://github.com/oneclick/rubyinstaller/) which was used for Ruby-2.3 and older.
It is licensed under the 3-clause Modified BSD License.

In contrast to the old RubyInstaller it does not provide its own DevKit, but makes use of the rich set of [MINGW libraries](https://github.com/Alexpux/MINGW-packages) from the [MSYS2 project](https://msys2.github.io/).
It therefore integrates well into MSYS2 after installation on the target system to provide a build-and-runtime environment for installation of gems with C-extensions.
This and more changes are documented in the [CHANGELOG](https://github.com/oneclick/rubyinstaller2/blob/master/CHANGELOG-2.4.md#rubyinstaller-241-1---2017-05-25).

## Using the Installer on a target system

- Download and install the latest RubyInstaller2: https://github.com/larskanis/rubyinstaller2/releases

The non-Devkit installer file is enough to use pure Ruby gems or fat binary gems for x64-mingw32 or x86-mingw32.
In order to install C based source gems, it's recommended to use the Devkit installer version.
It installs a MSYS2/MINGW build environment into the ruby directory that ships common build tools and libraries.

Some gems require additional packages, which can be installed per `pacman`. See below.
Its also possible to install MSYS2 manually from https://msys2.github.io/ and run `ridk install` afterwards to add non default, but required development tools.
For unattended install of Ruby and MSYS2 see the [FAQ chocolatey install](https://github.com/oneclick/rubyinstaller2/wiki/FAQ#user-content-choco-install).

### The `ridk` command

`ridk` is a cmd/powershell script which can be used to install MSYS2 components, to issue MSYS commands like `pacman` or to set environment variables for using MSYS2 development tools from the running shell.

See `ridk help` for further options:

```sh
  Usage:
      C:/Ruby24-x64/bin/ridk.cmd [option]

  Option:
      install                   Install MSYS2 and MINGW dev tools
      exec <command>            Execute a command within MSYS2 context
      enable                    Set environment variables for MSYS2
      disable                   Unset environment variables for MSYS2
      version                   Print RubyInstaller and MSYS2 versions
      use                       Switch to a different ruby version
      help | --help | -? | /?   Display this help and exit
```

`ridk enable` can be used to enable MSYS2 development tools on the running console.
This makes `sh`, `pacman`, `make` etc. available on the command line.
See [the Wiki](https://github.com/oneclick/rubyinstaller2/wiki/The-ridk-tool) for further instructions to the `ridk` command.

### Install gems with C-extensions and additional library dependencies

The base MSYS2 setup includes compilers and other build tools, but doesn't include libraries or DLLs that some gems require as their dependencies.
Fortunately many of the required libraries are available through the MSYS2 repositories.
They can be installed per `ridk exec pacman -S mingw-w64-x86_64-libraryname` similar to `apt-get` on Linux.
Exchange the prefix `mingw-w64-x86_64` by `mingw-w64-i686` for the 32-bit RubyInstaller.

For instance these popular gems can be installed like so from the source gem:

- To install `sqlite3` gem:
  ```sh
    ridk exec pacman -S mingw-w64-x86_64-sqlite3
    gem install sqlite3 --platform ruby
  ```
- To install `nokogiri` gem:
  ```sh
    ridk exec pacman -S mingw-w64-x86_64-libxslt
    gem install nokogiri --platform ruby -- --use-system-libraries
  ```

Some gems are properly labeled to install dependent libraries per pacman.
See [the wiki](https://github.com/oneclick/rubyinstaller2/wiki/For-gem-developers#msys2-library-dependency) how such a label can be added to gems.
Also refer the [FAQ](https://github.com/larskanis/rubyinstaller2/wiki/FAQ) for additional install recommendations.


## Building the Installer

This repository provides the packaging tasks to build RubyInstaller setup executables and 7zip files.
It doesn't compile any sources, but makes use of the [MSYS2-MINGW repository](https://github.com/Alexpux/MINGW-packages) and the [RubyInstaller2 pacman repository](https://github.com/oneclick/rubyinstaller2-packages) to download binaries and dependent libraries.

### Automatic build on Github Actions

The installer is regularly built on [Github Actions](https://github.com/oneclick/rubyinstaller2/actions) for each push to the github repository.
The runner also executes the installer and runs all RubyInstaller tests and [ruby-spec](https://github.com/ruby/spec) on it, so that we are notified about breaking changes.
In addition to this, a daily build of the latest ruby development snapshot is compiled and packaged as RubyInstaller files.
It can be downloaded from [github releases](https://github.com/oneclick/rubyinstaller2/releases/tag/rubyinstaller-head).
Check the [wiki on how to use](https://github.com/oneclick/rubyinstaller2/wiki/For-gem-developers#user-content-appveyor) ruby-head versions for your CI builds.


### Build RubyInstaller2 on your own machine:

- Make sure you have a working RubyInstaller-2.4+ and Git installation
- Ensure you have MSYS2 installed either by a RubyInstaller-Devkit version or per `ridk install` with default options
- Install the latest Inno-Setup (unicode) from http://www.jrsoftware.org/isdl.php
- Run **cmd.exe** and add **iscc.exe** to PATH:
  ```sh
    set PATH=%PATH%;"c:\Program Files (x86)\Inno Setup 6"
  ```
- Clone RubyInstaller2 and install dependencies:
  ```sh
    git clone https://github.com/larskanis/rubyinstaller2
    cd rubyinstaller2
    bundle install
    rake -T
  ```
- The last command lists all available RubyInstaller build targets.
  The build targets consists of the following parts:
  ```
    rake ri:ruby-3.0.4-x86-msvcrt:archive-7z
          ^      ^      ^    ^        ^- "archive-7z"     => 7z archive of the rubyinstaller files
          |      |      |    |           "installer-inno" => executable installer file
          |      |      |    '------- "msvcrt" => older type of C standard library
          |      |      |             "ucrt"   => new type of C standard library
          |      |      '------- "x86" => 32 bit ruby and MSYS2 version
          |      |               "x64" => 64 bit version
          |      '------ "x.x.x" => ruby version to build
          |              "head"  => latest development snapshot of ruby
          '------ "ri"      => RubyInstaller without Devkit
                  "ri-msys" => RubyInstaller with MSYS2 based Devkit
  ```
- Copy and paste the interesting one on the command line.
- If everything works well, you will find the final setup and archive files like so:
  * `packages/ri-msys/recipes/installer-inno/rubyinstaller-devkit-<VERSION>-<ARCH>.exe`
  * `packages/ri/recipes/archive-7z/rubyinstaller-<VERSION>-<ARCH>.7z`


## Known Issues

- It's best to avoid installation into a PATH containing spaces. Some gems won't install.
- Also refer to [the issue list](https://github.com/larskanis/rubyinstaller2/issues).
