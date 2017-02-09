require "base_task"

class RubyPackage < BaseTask
  def initialize(*args)
    super
    self.rubyver = File.basename(compiledir).gsub("ruby-", "")

    self.pkgbuild = File.join(compiledir, "PKGBUILD")
    File.read(pkgbuild) =~ /^pkgrel=(\d+)$/
    self.pkgrel = $1 or raise("'pkgrel' not defined in #{pkgbuild}")
    self.rubyver_pkgrel = "#{rubyver}-#{pkgrel}"
    self.rubyver2 = rubyver[/^\d+\.\d+/]

    self.git_commit = `git rev-parse HEAD`.chomp[0, 7]

    case arch
    when 'x64'
      self.pacman_arch = "mingw-w64-x86_64"
      self.ruby_arch = "x64-mingw32"
      self.mingwdir = "mingw64"
      self.default_instdir = "C:\\Ruby#{rubyver2.gsub(".","")}-x64"
    when 'x86'
      self.pacman_arch = "mingw-w64-i686"
      self.ruby_arch = "i386-mingw32"
      self.mingwdir = "mingw32"
      self.default_instdir = "C:\\Ruby#{rubyver2.gsub(".","")}"
    else
      raise "invalid arch #{arch}"
    end
  end
end
