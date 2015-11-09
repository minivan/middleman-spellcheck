require "middleman-core"
require "middleman-spellcheck/version"
require "middleman-spellcheck/cli"

::Middleman::Extensions.register(:spellcheck) do
  require "middleman-spellcheck/extension"
  ::Middleman::Spellcheck::SpellcheckExtension
end
