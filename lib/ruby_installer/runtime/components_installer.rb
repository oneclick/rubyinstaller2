require "rake"

module RubyInstaller
module Runtime
class ComponentsInstaller < Rake::Application
  attr_reader :installable_components

  def initialize
    super

    @task_consts = Dir[File.expand_path("../components/??_*.rb", __FILE__)].sort.map do |comppath|
      require comppath

      idx, tname = File.basename(comppath, ".rb").split("_", 2)
      const_name = tname.sub(/^[a-z\d]*/) { |match| match.capitalize }
              .gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
      [idx.to_i, tname, Components.const_get(const_name)]
    end

    define_tasks
  end

  def reload
    clear
    define_tasks
  end

  def install(component_names)
    collect_command_line_tasks(component_names)
    top_level
  end

  private

  def define_tasks
    @installable_components = @task_consts.map do |idx, tname, task_const|
      t = define_task(task_const, tname => task_const.depends)
      t.task_index = idx
      t
    end

    # Do nothing if nothing is requested
    define_task(Rake::Task, :default)
  end
end
end
end
