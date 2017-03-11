require "erb"
require "fileutils"

module RubyInstaller
module Build
class ErbCompiler
  include Utils

  attr_reader :erb_filename
  attr_reader :erb_filename_abs

  def initialize(erb_file_rel)
    @erb_filename = erb_file_rel
    @erb_filename_abs = ovl_expand_file(erb_file_rel)
    @erb = ERB.new(File.read(@erb_filename_abs, encoding: "UTF-8"))
    @erb.filename = erb_file_rel
  end

  def result_filename
    @erb.filename.sub(/\.erb$/, "")
  end

  def result
    @erb.result(binding)
  end

  def write_result(filename=nil)
    filename ||= result_filename
    FileUtils.mkdir_p File.dirname(filename)
    File.binwrite(filename, result)
    filename
  end

  def include(file_rel)
    File.read(ovl_expand_file(file_rel), encoding: "UTF-8")
  end

  def include_erb(erb_file_rel)
    self.class.new(erb_file_rel).result
  end

  # Quote a text string with the quotation rules of the resulting files.
  def q(text)
    meth = case result_filename
    when /\.iss$/ then :q_inno
    else raise "can not determine quote rules for #{result_filename}"
    end
    # redefine method q()
    self.class.send(:remove_method, :q)
    self.class.send(:define_method, :q, &method(meth))
    q(text)
  end

  def q_inno(text)
    '"' + text.gsub('"', '""') + '"'
  end
end
end
end
