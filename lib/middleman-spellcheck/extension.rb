require 'middleman-spellcheck/spellchecker'
require 'middleman-spellcheck/cli'
require 'nokogiri'

module Middleman
  module Spellcheck
    class SpellcheckExtension < Extension
      REJECTED_EXTS = %w(.css .js .coffee)
      ALLOWED_WORDS = []
      option :page, "/*", "Run only pages that match the regex through the spellchecker"
      option :tags, [], "Run spellcheck only on some tags from the output"
      option :allow, [], "Allow specific words to be misspelled"
      option :ignored_exts, [], "Ignore specific extensions (ex: '.xml')"
      option :ignore_regex, false, "Ignore regex matches"
      option :lang, "en", "Language for spellchecking"
      option :cmdargs, "", "Pass alternative command line arguments"
      option :debug, 0, "Enable debugging (for developers only)"
      option :dontfail, false, "Don't fail because misspelled words are found"
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

        builder.say_status :spellcheck, "Spellchecks done. #{total_misspelled.length} misspelling(s) found.", :blue

        unless total_misspelled.empty? 
          if options.dontfail
            builder.say_status :spellcheck, "dontfail is set! Builder will ignore misspellings.", :yellow
          else
            desc = "Build failed. There are spelling errors."
            raise Thor::Error, desc
          end
        end
      end

      def select_content(resource)
        rendered_resource = resource.render(layout: false)
        doc = Nokogiri::HTML.fragment(rendered_resource)
        doc.search('code,style,script').each(&:remove)

        if options.tags.empty?
          doc.text
        else
          select_tagged_content(doc, option_tags)
        end
      end

      def regex_filter_content(text)
        if options.ignore_regex
          text.to_s.gsub options.ignore_regex , ' '
        else
          text
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
        run_check(resource, lang)
      end

      def run_check(resource, lang)
        text = select_content(resource)
        text = regex_filter_content(text)
        results = Spellchecker.check(text, lang)
        results = exclude_allowed(resource, results)
        results.reject { |entry| entry[:correct] }
      end

      def exclude_allowed(resource, results)
        results.reject { |entry| allowed_words(resource).include? entry[:word].downcase }
      end

      def allowed_words(resource)
        words_ok = if options.allow.is_a? Array
                    options.allow
                  else
                    [options.allow]
                  end
        words_ok += allowed_words_frontmatter(resource)
        words_ok += allowed_words_file
        words_ok.map(&:downcase)
      end

      def allowed_words_frontmatter(resource)
        words_ok = []
        if resource.data.include?("spellcheck-allow") then
          allowed_tmp = resource.data["spellcheck-allow"]
          words_ok += if allowed_tmp.is_a? Array
                       allowed_tmp
                     else
                       [allowed_tmp]
                     end
        end
        words_ok
      end

      def allowed_words_file
        allow_file = nil
        if app.config.defines_setting?(:spellcheck_allow_file)
          allow_file = app.config[:spellcheck_allow_file]
        end
        if ALLOWED_WORDS.empty? && allow_file != nil
          lines = File.read(allow_file)
          lines.split("\n").each do |line|
            next if line =~ /^#/ or line =~ /^$/
            ALLOWED_WORDS << line.partition('#').first.strip
          end
        end
        ALLOWED_WORDS
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
