# truncato

*truncato* is a Ruby library for truncating HTML strings keeping the markup valid.

## Installation

In your `Gemfile`:

```ruby
gem 'truncato'
```

## Usage

```ruby
Truncato.truncate "<p>Hi there</p>", max_length: 8, tail: "..." => "<p>Hi...</p>"
```

The configuration options are:

* `max_length`: The size, in characters, to truncate (30 by default)
* `tail`: The string to append when the truncation occurs ('...' by default)

## Performance

Truncato was designed with performance in mind. Its main motivation was that existing libs couldn't truncate a multiple-MB document into a few-KB one in a reasonable time. It uses the [Nokogiri](http://nokogiri.org/) SAX parser.

