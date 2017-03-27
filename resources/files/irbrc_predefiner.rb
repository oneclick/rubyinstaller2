require 'irb'

irbrc_file = IRB.enum_for(:rc_file_generators).first.call(IRB::IRBRC_EXT)

if irbrc_file && !File.exist?(irbrc_file)
  File.write(irbrc_file, <<-EOT)
require 'irb/ext/save-history'
require 'irb/completion'

IRB.conf[:SAVE_HISTORY] = 200
  EOT
end
