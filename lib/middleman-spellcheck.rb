require "middleman-core"
require "middleman-spellcheck/version"

::Middleman::Extensions.register(:spellcheck) do
    require "middleman-spellcheck/extension"
      ::Middleman::Spellcheck
end
