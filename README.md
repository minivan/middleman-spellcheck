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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks

Special thanks to [Readbeard-Tech](https://rubygems.org/profiles/redbeard-tech) for the [spellchecker](https://rubygems.org/gems/spellchecker) gem, which this code is based upon.
