require "ostruct"

class RubyPackage < OpenStruct
  def initialize(*args)
    super
    self.rubyver = File.basename(compiledir).gsub("ruby-", "")

    self.pkgbuild = File.join(compiledir, "PKGBUILD")
    File.read(pkgbuild) =~ /^pkgrel=(\d+)$/
    self.pkgrel = $1 or raise("'pkgrel' not defined in #{pkgbuild}")
    self.rubyver_pkgrel = "#{rubyver}-#{pkgrel}"

    self.rake_namespace = "ruby-#{rubyver}-#{arch}"
    self.rubyver2 = rubyver[/^\d+\.\d+/]
  end
end
