
## RubyInstaller1 -> RubyInstaller2

- Built with gcc compiler suite 6.3 from the MSYS2 repository.
- No devkit anymore, but integrates MSYS2 libraries and toolchain.
- `Encoding.default_external` is now `UTF-8` (no longer ancient cpXYZ encoding when reading files).
- RubyInstaller2 uses a separate DLL directory to avoid conflicting DLLs in the PATH.
- RubyInstaller2 uses a DLL loading mechanism which ignores the PATH environment variable for DLL lookups, but provides a API for DLL directory addition.
- RubyInstaller2 bundles it's own SSL/TLS CA list derived from the current Mozilla CA list.
- Ability to add use rubyinstaller-build.gem for customized Ruby-Applications.
- CI tests on appveyor for each git commit.
