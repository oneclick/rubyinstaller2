class RubyPackage < RubyInstaller::Build::Openstruct
  def initialize(*args)
    super
    self.rubyver = File.basename(compiledir).gsub("ruby-", "")

    self.pkgbuild = File.join(compiledir, "PKGBUILD")
    File.read(pkgbuild) =~ /^pkgrel=(\d+)$/
    self.pkgrel = $1 or raise("'pkgrel' not defined in #{pkgbuild}")
    self.rubyver_pkgrel = "#{rubyver}-#{pkgrel}"
    self.rubyver2 = rubyver[/^\d+\.\d+/]

    self.install_gems = %w[rb-readline-0.5.4]

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

ruby_packages = Dir["recipes/compile/ruby-*"].map do |compiledir|
  %w[x64 x86].map do |arch|
    RubyPackage.new( compiledir: compiledir, arch: arch, rootdir: File.join(__dir__, "..") ).freeze
  end
end.flatten

ruby_packages.each do |pack|

  nsp = "ruby-#{pack.rubyver}-#{pack.arch}"
  namespace nsp do
    compile = CompileTask.new( package: pack )
    unpack = UnpackTask.new( package: pack, compile_task: compile )
    sandbox = SandboxTask.new( package: pack, unpack_task: unpack )
    InstallerInnoTask.new( package: pack, sandbox_task: sandbox )
    Archive7zTask.new( package: pack, sandbox_task: sandbox )
  end

  desc "Build all for #{nsp}"
  task nsp => ["#{nsp}:installer-inno", "#{nsp}:archive-7z"]

  desc "Build installers for all rubies"
  task :default => nsp
end
