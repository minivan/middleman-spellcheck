require 'spellchecker'

module Middleman
  module Spellcheck
    class SpellcheckExtension < Extension
      option :page, "/*", "Run only pages that match the regex through the spellchecker"

      def after_build(builder)
        filtered = filter_resources(app, options.page)
        total_misspelled = []

        filtered.each do |resource|
          builder.say_status :spellcheck, "Running spell checker for #{resource.url}", :blue
          current_misspelled = run_check(resource.render(layout: false))
          current_misspelled.each do |misspell|
            builder.say_status :misspell, error_message(misspell), :red
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
