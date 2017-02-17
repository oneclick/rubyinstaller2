require "rake"
require "ruby_installer/build"

module RubyInstaller
module Build
class BaseTask < Openstruct
  include Rake::DSL
  include Build::Utils
end
end
end
