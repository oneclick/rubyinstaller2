# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby_installer'

Gem::Specification.new do |spec|
  spec.name          = "rubyinstaller"
  spec.version       = RubyInstaller::GEM_VERSION
  spec.authors       = ["Lars Kanis"]
  spec.email         = ["lars@greiz-reinsdorf.de"]

  spec.summary       = %q{MSYS2 based RubyInstaller for Windows}
  spec.description   = %q{This project provides an Installer for Ruby on Windows based on the MSYS2 toolchain.}
  spec.homepage      = "https://github.com/larskanis/rubyinstaller2"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "minitest", "~> 5.0"
end
