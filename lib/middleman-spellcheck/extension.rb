require 'spellchecker'
require 'nokogiri'

module Middleman
  module Spellcheck
    class SpellcheckExtension < Extension
      option :page, "/*", "Run only pages that match the regex through the spellchecker"
      option :tags, [], "Run spellcheck only on some tags from the output"

      def after_build(builder)
        filtered = filter_resources(app, options.page)
        total_misspelled = []

        filtered.each do |resource|
          builder.say_status :spellcheck, "Running spell checker for #{resource.url}", :blue
          current_misspelled = run_check(select_content(resource))
          current_misspelled.each do |misspell|
            builder.say_status :misspell, error_message(misspell), :red
          end
          total_misspelled += current_misspelled
        end

        unless total_misspelled.empty?
          raise Thor::Error, "Build failed. There are spelling errors."
        end
      end

      def select_content(resource)
        rendered_resource = resource.render(layout: false)
        doc = Nokogiri::HTML(rendered_resource)

        if options.tags.empty?
          doc.text
        else
          select_tagged_content(doc, option_tags)
        end
      end

      def option_tags
        if options.tags.is_a? Array
          options.tags
        else
          [options.tags]
        end
      end

      def select_tagged_content(doc, tags)
        tags.map { |tag| texts_for_tag(doc, tag.to_s) }.flatten.join(' ')
      end

      def texts_for_tag(doc, tag)
        doc.css(tag).map(&:text)
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
