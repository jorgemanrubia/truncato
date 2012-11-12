# truncato

*truncato* is a Ruby library for truncating HTML strings keeping the markup valid.

## Installation

In your `Gemfile`:

```ruby
gem 'truncato'
```
 
## Usage

```ruby
Truncato.truncate "<p>some text</p>", max_length: 4 => "<p>s...</p>"
Truncato.truncate "<p>some text</p>", max_length: 4, count_tags: false => "<p>some...</p>"
```

The configuration options are:

* `max_length`: The size, in characters, to truncate (`30` by default)
* `tail`: The string to append when the truncation occurs ('...' by default)
* `count_tags`: Boolean value indicating whether tags size should be considered when truncating (`true` by default)

## Performance

Truncato was designed with performance in mind. Its main motivation was that existing libs couldn't truncate a multiple-MB document into a few-KB one in a reasonable time. It uses the [Nokogiri](http://nokogiri.org/) SAX parser.

