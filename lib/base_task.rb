require "rake"
require "build_utils"

class BaseTask
  include Rake::DSL
  include BuildUtils

  def initialize(hash={})
    @__attrs = {}
    hash.each do |k,v|
      send("#{k}=", v)
    end
  end

  def method_missing(meth, *args)
    if meth=~/\A(.*)=\z/ && args.length == 1
      attr = $1
      self.class.class_eval do
        define_method(attr) do
          @__attrs[attr]
        end
        define_method(meth) do |val|
          @__attrs[attr] = val
        end
      end
      @__attrs[attr] = args.first
    else
      super
    end
  end
end
