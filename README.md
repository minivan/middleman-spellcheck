# Middleman-Spellchecker

Run a spell checker job after the app is built. Requires 'aspell'.

## Installation

Add this line to your application's Gemfile:

    gem 'middleman-spellcheck'

And then execute:

    $ bundle

Add the following to middleman's `config.rb`:

    activate :spellcheck

Spellcheck is run automatically after build, but you can also check individual files and subdirectories:

```
middleman spellcheck source/about.html
middleman spellcheck source/blog/
```

## Usage

There are several ways to select what content will be checked.

1. To spellcheck only some resources using a regex with the URL:

    ```ruby
    activate :spellcheck, page: "documentation/*" # you can use regexes, too, e.g. /post_[1-9]/
    ```

2. To limit which tags the spell checker will only run through:

    ```ruby
    activate :spellcheck, tags: :p  # pass an array of tags if you have more!
    ```

3. To ignore sections by using css selectors
    For example, to ignore all sections with a class of `CodeRay`:

    ```ruby
    activate :spellcheck, ignore_selector: '.CodeRay'
    ```

    Or to ignore all tables in a document:

    ```ruby
    activate :spellcheck, ignore_selector: 'table'
    ```

    Or to ignore all `<p class="technical-jargon">`:
    ```ruby
    activate :spellcheck, ignore_selector: 'p.technical-jargon'
    ```

    To ignore multiple selectors, seperate them with a comma
    ```ruby
    activate :spellcheck, ignore_selector: 'p.technical-jargon, .CodeRay'
    ```

4. Middleman-spellcheck automatically ignores `.css`, `.js`, & `.coffee` file
extensions. If there are some additional file type extensions that you would
like to skip:

    ```ruby
    activate :spellcheck, ignored_exts: [".xml", ".png"]
    ```

To select a dictionary used by a spellchecker, use lang: option. For
example, to use Polish dictionary, use:

```ruby
activate :spellcheck, lang: "pl"
```

If you define the ``lang`` metadata in your pages / articles, then spellcheck will use those language.

## Options


For warnings only (allow build to pass), use `dontfail` option.
This is helpful when you want to give yourself a chance to fix mistakes or false hits gradually and
not fail each time you build.

```ruby
activate :spellcheck, dontfail: 1
```

You can also disable the automatic spellcheck after build (and only run manual checks from the command line):

```ruby
activate :spellcheck, run_after_build: false
```

Advanced users wishing to invoke Middleman-spellcheck backend (Aspell) with
a custom command line may find cmdargs: useful. Please note that "-a" is a
mandatory flag which one must specify in order for middleman-spellcheck to
work. Other flags are up to the user. See Aspell's man page for more
details.

```ruby
activate :spellcheck, cmdargs: "-a -l pl"
```

For developers interested in extending Middleman-spellcheck and for those
who encountered issues, useful might be debug: option, which will turn on
extensive amount of debugging.

```ruby
activate :spellcheck, lang: "en", debug: 1
```

If there are some words that you would like to be allowed you can pass them to the allow option as an array. **Depricated - Please see the "Fixing spelling mistakes" section for now prefered way to include allowed words

```ruby
activate :spellcheck, allow: ["Gooby", "pls"]
```

You can also pass a regex to the `ignore_regex` option. Any match will be ignored.
For example to remove words in quotes
```ruby
activate :spellcheck, lang: "en", ignore_regex: /\s('|")\w*('|")(\s|\.|,)/
```

## Fixing spelling mistakes & false positives

The `middleman-spellchecker` extension is likely to generate large number
of false-positives, e.g.: words which the spellchecker will consider
incorrect (not present in a dictionary), which yet may have a valid meaning
in the article's context. Common problems are acronyms, technical terms and
names. To solve this, `middleman-spellcheck` offers two solutions:

1. The `spellcheck_allow_file` file, which points to the path with a file
containing words considered correct. Author of the website may decide which
words are allowed to be used site-wide. Example: if you write a lot about
IBM products, this file would have names such as "IBM", "AIX" or "DB/2".

To set the global file, use the following clause in your `config.rb`:

    ```set :spellcheck_allow_file, "./data/words_allowed.txt"```

2. The `spellcheck-allow` keyword in a frontmatter, which will work in the
context of this particular article, but not other articles. Example: your
blog is about IBM, but 1 article is about AirBnB. You'd put `AirBnB` into
your front-matter.


To use 2nd solution, add the following to your frontmatter:

    ```
    title: "Blog about IBM"
    ...
    spellcheck-allow:
    - "AirBnB"```
    
    Another example
    
    ```
    title: "Some time ago"
    ...
    spellcheck-allowed:
    - GitHub
    - Linux
    ```

The `middleman-spellcheck` also comes with a simple CLI for fixing many
problems in your articles. To invoke:

    ```middleman spellcheck source/blog/2015-11-01-nginx-on-travis-ci.md --fix```

This will pull up simple CLI menu and for each misspelled word, you'll have
a following choice

| Key to press | Effect |
|--------------|--------|
| g | Add the word to the `spellcheck_allow_file` |
| f | Add the word to this article's front-matter |
| i | Ignore the word for now and deal with it later |


After the run is finished, `middleman-spellchecker` will write a fixed file
to `source/blog/2015-11-01-nginx-on-travis-ci.md.fixed`. This is a safe
choice for not creating damage. If you don't want to fiddle with it, the
`--inplace` switch will make changes dynamically, and the input file will
get overwritten.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks

Special thanks to [Readbeard-Tech](https://rubygems.org/profiles/redbeard-tech) for the [spellchecker](https://rubygems.org/gems/spellchecker) gem, which this code is based upon.
