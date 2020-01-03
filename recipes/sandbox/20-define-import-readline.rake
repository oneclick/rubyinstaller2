# Define files that are imported into the package either from the current working dir or from the rubyinstaller-build gem.

# Ruby-2.7 bundles reline, so that there's no need to backport
if package.rubyver2 < "2.7"

  %w[
    readline.rb
    reline.rb
    reline/ansi.rb
    reline/config.rb
    reline/general_io.rb
    reline/history.rb
    reline/key_actor/base.rb
    reline/key_actor/emacs.rb
    reline/key_actor/vi_command.rb
    reline/key_actor/vi_insert.rb
    reline/key_actor.rb
    reline/key_stroke.rb
    reline/kill_ring.rb
    reline/line_editor.rb
    reline/unicode/east_asian_width.rb
    reline/unicode.rb
    reline/version.rb
    reline/windows.rb
  ].each do |f|
    self.import_files["resources/files/#{f}"] = "lib/ruby/site_ruby/#{f}"
  end
end
