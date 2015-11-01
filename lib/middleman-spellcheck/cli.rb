module Middleman
  module Cli
    # This class provides an "spellchecl" command for the middleman CLI.
    class Spellcheck < Thor
      include Thor::Actions
      namespace :spellcheck
      desc "spellcheck FILE", "Run spellcheck on given file or path"
      def spellcheck(path)
        app = ::Middleman::Application.server.inst

        articles = app.blog.articles.select{|article|
          article.source_file.sub(Dir.pwd,'').sub(%r{^/},'')[/^#{Regexp.escape(path)}/]
        }
        if articles.empty?
          $stderr.puts "File / Directory #{path} not exist"
          exit 1
        end
        ext = app.extensions[:spellcheck]
        articles.each do |resource|
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
