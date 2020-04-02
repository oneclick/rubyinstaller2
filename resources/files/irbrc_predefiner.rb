require 'irb'

irbrc_file = IRB.enum_for(:rc_file_generators).first.call(IRB::IRBRC_EXT)

if irbrc_file && !File.exist?(irbrc_file)
  File.write irbrc_file, <<-EOT
require 'irb/ext/save-history'
require 'irb/completion'
IRB.conf[:SAVE_HISTORY] = 200
  EOT
end

# Try to convert .irb_history from locale to UTF-8, if it isn't encoded properly.
# This is for transition from CP* encodings of RbReadline to UTF-8 or Reline.
history_file = IRB.rc_file("_history")
if File.exist?(history_file) && !(hist=File.read(history_file, encoding: 'utf-8')).valid_encoding?
  hist = hist.encode('utf-8', Encoding.find("locale"))
  if hist.valid_encoding?
    File.write(history_file, hist)
  end
end
