require "erb"
require "fileutils"

module RubyInstaller
module Build

# This class processes a template file with ERB.
# The ERB template is either taken from the current directory or, if it doesn't exist, from the gem root directory.
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

  # Create a new ERB object to process a template.
  #
  # The ERB template +erb_file_rel+ should be a relative path.
  # It is either taken from the current directory or, if it doesn't exist, from the gem root directory.
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

  # Returns the ERB content as String with UTF-8 encoding.
  #
  # A Box instance is used as binding to process the ERB template.
  # All method calls are redirected to the +task+ object.
  def result(task=nil)
    box = Box.new(self, task)
    @erb.result(box.binding)
  end

  # Write the ERB result to a file in UTF-8 encoding.
  #
  # See #result
  #
  # If no file name is given, it is derived from the template file name by cutting the +.erb+ extension.
  # If the file path contains non-exising directories, they are created.
  def write_result(task=nil, filename=nil)
    filename ||= result_filename
    FileUtils.mkdir_p File.dirname(filename)
    File.binwrite(filename, result(task))
    filename
  end
end
end
end
