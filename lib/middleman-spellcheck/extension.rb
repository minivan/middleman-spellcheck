require 'middleman-spellcheck/spellchecker'
require 'nokogiri'

module Middleman
  module Spellcheck
    class SpellcheckExtension < Extension
      REJECTED_EXTS = %w(.css .js .coffee)
      option :page, "/*", "Run only pages that match the regex through the spellchecker"
      option :tags, [], "Run spellcheck only on some tags from the output"
      option :allow, [], "Allow specific words to be misspelled"
      option :ignored_exts, [], "Ignore specific extensions (ex: '.xml')"
      option :lang, "en", "Language for spellchecking"

      def after_build(builder)
        filtered = filter_resources(app, options.page)
        total_misspelled = []

        filtered.each do |resource|
          builder.say_status :spellcheck, "Running spell checker for #{resource.url}", :blue
          current_misspelled = run_check(select_content(resource), options.lang)
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
                             .reject { |resource| option_ignored_exts.include? resource.ext }
      end

      def run_check(text, dictionary="en")
        results = Spellchecker.check(text, dictionary)
        results = exclude_allowed(results)
        results.reject { |entry| entry[:correct] }
      end

      def exclude_allowed(results)
        results.reject { |entry| option_allowed.include? entry[:word].downcase }
      end

      def option_allowed
        allowed = if options.allow.is_a? Array
                    options.allow
                  else
                    [options.allow]
                  end
        allowed.map(&:downcase)
      end

      def option_ignored_exts
        ignored_exts = if options.ignored_exts.is_a? Array
                         options.ignored_exts
                       else
                         [options.ignored_exts]
                       end
        REJECTED_EXTS + ignored_exts
      end

      def error_message(misspell)
        "The word '#{misspell[:word]}' is misspelled"
      end
    end
  end
end
