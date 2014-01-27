require 'middleman-spellcheck/spellchecker'
require 'pry-debugger'

module Middleman
  module Spellcheck < Extension
    def after_build(builder)
      binding.pry
    end
  end
end
