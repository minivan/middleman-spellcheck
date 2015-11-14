require 'middleman-spellcheck/spellchecker'
require 'middleman-spellcheck/cli'
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
      option :cmdargs, "", "Pass alternative command line arguments"
      option :debug, 0, "Enable debugging (for developers only)"
      option :dontfail, 0, "Don't fail when misspelled words are found"
      option :run_after_build, true, "Run Spellcheck after build"

      def after_build(builder)
        return if !options.run_after_build
        Spellchecker.cmdargs=(options.cmdargs)
        Spellchecker.debug_enabled=(options.debug)
        filtered = filter_resources(app, options.page)
        total_misspelled = []

        filtered.each do |resource|
          builder.say_status :spellcheck, "Running spell checker for #{resource.url}", :blue
          current_misspelled = spellcheck_resource(resource)
          current_misspelled.each do |misspell|
            builder.say_status :misspell, error_message(misspell), :red
          end
          total_misspelled += current_misspelled
        end

        unless total_misspelled.empty?
          if options.dontfail >= 1
            print "== :dontfail set! Will issue warning only, but not fail.\n"
            print estr, "\n"
          else
            estr = "Build failed. There are spelling errors."
            raise Thor::Error, estr
          end
        end
      end

      def select_content(resource)
        rendered_resource = resource.render(layout: false)
        doc = Nokogiri::HTML.fragment(rendered_resource)

        doc.search('code,style,script').each(&:remove)
        doc.search('table[@class = "CodeRay"]').each(&:remove)

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

      def spellcheck_resource(resource)
        lang =
          if options.lang.respond_to?(:call)
            options.lang.call(resource)
          elsif resource.respond_to?(:lang) and resource.lang
            resource.lang.to_s
          else
            options.lang
          end
        run_check(select_content(resource), lang)
      end

      def run_check(text, lang)
        results = Spellchecker.check(text, lang)
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
