require 'spellchecker'

module Middleman
  module Spellcheck
    class SpellcheckExtension < Extension
      def after_build(builder)
        filtered = filter_resources(app, "/")
        total_misspelled = []

        filtered.each do |resource|
          builder.shell.say("Running spell checker for #{resource.url}")
          current_misspelled = run_check(resource.render(layout: false))
          current_misspelled.each do |misspell|
            builder.shell.say(error_message(misspell))
          end
          total_misspelled += current_misspelled
        end

        unless total_misspelled.empty?
          raise Thor::Error, "Build failed. There are spelling errors."
        end
      end

      def filter_resources(app, pattern)
        app.sitemap.resources.select { |resource| resource.url.match(pattern) }
      end

      def run_check(text, dictionary="en")
        results = Spellchecker.check(text, dictionary)
        results.reject { |entry| entry[:correct] }
      end

      def error_message(misspell)
        "The word '#{misspell[:original]}' is misspelled"
      end
    end
  end
end
