require "rake"
require "ruby_installer/build"

module RubyInstaller
module Build
class BaseTask < Openstruct
  include Rake::DSL
  include Utils

  def initialize(thisdir: , **hash)
    super(hash)
    self.thisdir = thisdir

    ovl_glob(File.join(thisdir, "[0-9][0-9]-*.rake")).sort.each do |taskfile|
      eval_file(ovl_expand_file(taskfile))
    end
  end
end
end
end
