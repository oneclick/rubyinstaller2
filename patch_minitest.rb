# Patch minitest for compatibility with ruby-3.1
module Gem
  class Specification
    def required_ruby_version
      Gem::Requirement.default
    end
  end
end
