# enable MSYS2 usage as a vendorable helper library

# TODO: Find msys2 in non-default paths
msys_path = "c:/msys64".gsub("/", "\\")

msys_bin_path = File.join(msys_path, "usr/bin")
msystem = RUBY_PLATFORM=~/x64/ ? 'MINGW64' : 'MINGW32'

[msys_path, msys_bin_path].each do |path|
  path.gsub!("/", "\\")
end

unless ENV['PATH'].include?(msys_bin_path) then
  phrase = 'Temporarily enhancing PATH to include MSYS2...'
  if defined?(Gem)
    Gem.ui.say(phrase) if Gem.configuration.verbose
  else
    puts phrase
  end
  puts "Prepending #{msys_bin_path} to PATH" if $DEBUG
  ENV['PATH'] = msys_bin_path + ';' + ENV['PATH']
end
ENV['RI_DEVKIT'] = msys_path
ENV['MSYSTEM'] = msystem.upcase
