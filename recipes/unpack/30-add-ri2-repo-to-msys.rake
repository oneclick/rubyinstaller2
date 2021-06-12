directory File.dirname(self.repo_added)
file self.repo_added => [File.dirname(self.repo_added)] do |t|
  msys_path = RubyInstaller::Build.msys2_installation.msys_path
  pacman_conf = File.join(msys_path, "/etc/pacman.conf")

  if File.read(pacman_conf) =~ /^\[ci\.ri2\]/
    $stderr.puts "pacman repo 'ci.ri2' is already registered"
  else
    $stderr.puts "Register pacman repo 'ci.ri2'"
    File.open(pacman_conf, "a+") do |fd|
      fd.puts
      fd.puts "# Added for RubyInstaller2 packaging by #{__FILE__}"
      fd.puts <<-EOT
[ci.ri2]
Server = https://github.com/oneclick/rubyinstaller2-packages/releases/download/ci.ri2
      EOT
    end
    $stderr.puts "Populated #{ pacman_conf }:\n#{ File.read(pacman_conf) }"
  end

  # Import our key into the local pacman signature key database.
  key = File.read(File.expand_path("../appveyor-repo-key.asc", __FILE__))
  cmd = "gpg --homedir /etc/pacman.d/gnupg --verbose --batch --import - 2>&1"
#   cmd = "bash pacman-key --add -"
  $stderr.puts cmd.to_s
  io = IO.popen(cmd, "w+")
  io.puts key
  io.close_write
  loop do
    l = io.gets
    $stderr.puts "gpg: #{l.inspect}"
    break l if !l || l=~/imported|processed/i
  end
  # In docker container gpg often doesn't terminate, so that we don't wait for that it has been closed
  # io.close
  raise "pacman-key failed: #{res}" if $?.exitstatus!=0
  
  # Sign the imported key, so that it's trusted.
  sh "sh -c 'pacman-key --lsign-key BE8BF1C5'"
  
  # Download the new package database.
  sh "pacman -Sy"

  touch t.name
end
