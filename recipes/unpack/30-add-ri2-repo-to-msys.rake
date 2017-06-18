directory File.dirname(self.repo_added)
file self.repo_added => [File.dirname(self.repo_added)] do |t|
  msys_path = RubyInstaller::Build.msys2_installation.msys_path
  pacman_conf = File.join(msys_path, "/etc/pacman.conf")

  unless File.read(pacman_conf).include?("[ci.ri2]")
    File.open(pacman_conf, "a+") do |fd|
      fd.puts
      fd.puts "# Added for RubyInstaller2 packaging by #{__FILE__}"
      fd.puts <<-EOT
[ci.ri2]
Server = http://dl.bintray.com/larskanis/rubyinstaller2-packages
      EOT
    end
  end

  # Import our key into the local pacman signature key database.
  key = File.read(File.expand_path("../appveyor-repo-key.asc", __FILE__))
  cmd = "sh -c 'pacman-key --add -'"
  $stderr.puts cmd
  res = IO.popen(cmd, "w+") do |io|
    io.puts key
    io.close_write
    io.read
  end
  raise "pacman-key failed: #{res}" if $?.exitstatus!=0
  
  # Sign the imported key, so that it's trusted.
  sh "sh -c 'pacman-key --lsign-key BE8BF1C5'"
  
  # Download the new package database.
  sh "pacman -Sy"

  touch t.name
end
