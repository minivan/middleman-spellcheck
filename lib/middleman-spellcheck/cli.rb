module Middleman
  module Cli
    # This class provides an "spellchecl" command for the middleman CLI.
    class Spellcheck < Thor
      include Thor::Actions
      namespace :spellcheck
      desc "spellcheck FILE", "Run spellcheck on given file or path"
      def spellcheck(*paths)
        binding.pry
        app = ::Middleman::Application.server.inst

        resources = app.sitemap.resources.select{|resource|
          paths.any? {|path|
            resource.source_file.sub(Dir.pwd,'').sub(%r{^/},'')[/^#{Regexp.escape(path)}/]
          }
        }
        if resources.empty?
          $stderr.puts "File / Directory #{path} not exist"
          exit 1
        end
        ext = app.extensions[:spellcheck]
        resources.each do |resource|
          say_status :spellcheck, "Running spell checker for #{resource.url}", :blue
          current_misspelled = ext.spellcheck_resource(resource)
          current_misspelled.each do |misspell|
            say_status :misspell, ext.error_message(misspell), :red
          end
        end
      end
    end
  end
end
