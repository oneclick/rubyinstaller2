if RUBY_VERSION < "2.5"
  class String
    def grapheme_clusters
      chars
    end
  end

  class Array
    alias any_wo_arg? any?
    def any?(obj=nil, &block)
      obj ? any_wo_arg? { |o| o==obj } : any_wo_arg?(&block)
    end
  end
end

require 'reline' unless defined? Reline
Readline = Reline
