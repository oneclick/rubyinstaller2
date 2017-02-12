module RubyInstaller
module Components
class Base < Rake::Task
  include RubyInstaller::Colors

  attr_accessor :task_index

  def self.depends
    []
  end

  def initialize(*_)
    enable_colors
    super
  end
end
end
end
