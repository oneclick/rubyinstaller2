require "erb"

module RubyInstaller
module Build
class ErbCompiler
  include Utils

  def initialize(erb_file_rel)
    @erb = ERB.new(File.read(ovl_expand_file(erb_file_rel), encoding: "UTF-8"))
    @erb.filename = erb_file_rel
  end

  def result
    @erb.result(binding)
  end

  def write_result(filename=nil)
    filename ||= @erb.filename.sub(/\.erb$/, "")
    File.binwrite(filename, result)
    filename
  end

  def include(file_rel)
    File.read(ovl_expand_file(file_rel), encoding: "UTF-8")
  end

  def include_erb(erb_file_rel)
    self.class.new(erb_file_rel).result
  end

  def q(text)
    '"' + text.gsub('"', '""') + '"'
  end
end
end
end
