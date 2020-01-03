require 'irb'

irbrc_file = IRB.enum_for(:rc_file_generators).first.call(IRB::IRBRC_EXT)

if irbrc_file && !File.exist?(irbrc_file)
  File.write irbrc_file, <<-EOT
require 'irb/ext/save-history'
require 'irb/completion'

IRB.conf[:SAVE_HISTORY] = 200
  EOT
end

# Try to convert .irb_history from locale to default_external, if it isn't encoded properly.
# This is mainly for transition from CP* encodings to UTF-8.
history_file = IRB.rc_file("_history")
if File.exist?(history_file) && !(hist=File.read(history_file)).valid_encoding?
  hist = hist.encode(Encoding.default_external, Encoding.find("locale"))
  if hist.valid_encoding?
    File.write(history_file, hist)
  end
end
