# Middleman-Spellchecker

Run a spell checker job after the app is built. Requires 'aspell'.

## Installation

Add this line to your application's Gemfile:

    gem 'middleman-spellcheck'

And then execute:

    $ bundle

Add the following to middleman's `config.rb`:

    activate :spellcheck

## Usage

You can spellcheck only some resources using a regex with the URL:

```ruby
activate :spellcheck, page: "documentation/*" # you can use regexes, too, e.g. /post_[1-9]/
```

You can limit which tags the spell checker will only run through:

```ruby
activate :spellcheck, tags: :p  # pass an array of tags if you have more!
```

If there are some words that you would like to be allowed

```ruby
activate :spellcheck, allow: ["Gooby", "pls"]
```

Middleman-spellcheck automatically ignores `.css`, `.js`, & `.coffee` file
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

Middleman-spellcheck can issue many warnings if you run it over a new
content. If you want to give yourself a chance to fix mistakes gradually and
not fail each time you build, use :dontfail flag:

```ruby
activate :spellcheck, lang: en, dontfail: 1
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
activate :spellcheck, debug: 1
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks

Special thanks to [Readbeard-Tech](https://rubygems.org/profiles/redbeard-tech) for the [spellchecker](https://rubygems.org/gems/spellchecker) gem, which this code is based upon.
