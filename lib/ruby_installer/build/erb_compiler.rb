require "erb"
require "fileutils"

module RubyInstaller
module Build
class ErbCompiler
  class Box
    def initialize(co, task)
      @co = co
      @task = task
    end

    def method_missing(meth, *args, &block)
      @task.send(meth, *args, &block)
    end

    def binding
      Kernel.binding
    end

    # Quote a text string with the quotation rules of the resulting files.
    def q(text)
      meth = case @co.result_filename
        when /\.iss$/ then :q_inno
        else raise "can not determine quote rules for #{@co.result_filename}"
      end
      send(meth, text)
    end
  end

  include Utils

  attr_reader :erb_filename
  attr_reader :erb_filename_abs

  def initialize(erb_file_rel, result_file_rel=nil)
    @erb_filename = erb_file_rel
    @erb_filename_abs = ovl_expand_file(erb_file_rel)
    @erb = ERB.new(File.read(@erb_filename_abs, encoding: "UTF-8"))
    @result_file_rel = result_file_rel || erb_file_rel.sub(/\.erb$/, "")
    @erb.filename = @result_file_rel
  end

  def result_filename
    @result_file_rel
  end

  def result(task=nil)
    box = Box.new(self, task)
    @erb.result(box.binding)
  end

  def write_result(task=nil, filename=nil)
    filename ||= result_filename
    FileUtils.mkdir_p File.dirname(filename)
    File.binwrite(filename, result(task))
    filename
  end
end
end
end
