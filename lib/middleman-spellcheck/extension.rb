require 'middleman-spellcheck/spellchecker'

module Middleman
  module Spellcheck
    class SpellcheckExtension < Extension
      def after_build(builder)
        p "I'm here"
      end
    end
  end
end
