module Middleman
  module Cli
    # This class provides an "spellchecl" command for the middleman CLI.
    class Spellcheck < Thor
      include Thor::Actions

      check_unknown_options!

      namespace :spellcheck

      no_commands {
        def misspell_ask(misspell, allow_file)
          if not options[:fix]
            return false
          end

          print "-" * 70, "\n"
          print "'#{misspell[:word]}' is misspelled. What to do?:\n"
          print "g\tadd allowed word to '#{allow_file}'\n" if allow_file
          print "f\tadd allowed word to frontmatter\n"
          print "i\tignore word (deal with it later)\n"

          print "Select option and press ENTER:\n"
          STDIN.gets()[0]
        end

        def misspell_fixes_global(resource, words_allow_global, allow_file)
          open(allow_file, 'a') { |f|
            words_allow_global.each do |w|
              f.puts "#{w}\t#\t#{resource.source_file}\n"
            end
          }
        end

        def misspell_fixes_frontmatter(resource, words_allow_frontmatter)
          data = File.read(resource.source_file)
          if options[:inplace] then fn_ext = "" else ".fixed" end
          fn_fixed = "#{resource.source_file}#{fn_ext}"
          fixed = File.open(fn_fixed, "w")
          sep_tag_cnt = 0
          data.each_line do |line|
            if line =~ /^\-\-\-$/ then
              sep_tag_cnt += 1
            end

            if sep_tag_cnt == 2 then
              fixed.puts "spellcheck-allow:\n"
              words_allow_frontmatter.each do |w|
                fixed.puts "- \"#{w}\"\n"
              end
              fixed.puts "---\n"
              sep_tag_cnt = nil
            else
              fixed.puts line
            end
          end
          fixed.close()
          print "Fixed spellchecked file written to #{fn_fixed}\n"
        end
      }

      namespace :spellcheck
      desc "spellcheck FILE", "Run spellcheck on given file or path"
      method_option "fix", :type => :boolean, :aliases => "-f", :desc => "Fix spelling error interactively"
      method_option "inplace", :type => :boolean, :aliases => "-i", :desc => "Modify files in place (dangerous)"

      def spellcheck(*paths)
        app = ::Middleman::Application.server.inst

        resources = app.sitemap.resources.select{|resource|
          paths.any? {|path|
            resource.source_file.sub(Dir.pwd,'').sub(%r{^/},'')[/^#{Regexp.escape(path)}/]
          }
        }
        if resources.empty?
          $stderr.puts "File / Directory #{paths} not exist"
          exit 1
        end
        ext = app.extensions[:spellcheck]

        allow_file = app.config.defines_setting?(:spellcheck_allow_file) ?
              app.config[:spellcheck_allow_file] : nil
        if options[:fix] then
          print "Spellchecker fix mode on! Will attempt to white-list some words\n"
        end
        resources.each do |resource|
          say_status :spellcheck, "Running spell checker for #{resource.source_file}", :blue
          current_misspelled = ext.spellcheck_resource(resource)

          words_allow_frontmatter = []
          words_allow_global = []
          current_misspelled.each do |misspell|
            fix = misspell_ask(misspell, allow_file)
            was_fixed = true
            if    fix == 'g' then words_allow_global << misspell[:word]
            elsif fix == 'f' then words_allow_frontmatter << misspell[:word]
            else             was_fixed = false end

            if was_fixed
              say_status :spellcheck, "Fixed word #{misspell[:word]}"
            else
              say_status :misspell, ext.error_message(misspell), :red
            end
          end
          misspell_fixes_global(resource, words_allow_global, allow_file) unless words_allow_global.empty?
          misspell_fixes_frontmatter(resource, words_allow_frontmatter) unless words_allow_frontmatter.empty?
        end
      end

    end
  end
end
