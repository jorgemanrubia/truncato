# truncato

*truncato* is a Ruby library for truncating HTML strings keeping the markup valid.

## Installing

In your `Gemfile`

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

There is a benchmark included that generates a synthetic XML of 4MB and truncates it to 400 KB. You can run the benchmark using 

```ruby
rake truncato:benchmark
```

There is a also a comparison benchmark that tests the previous data with other alternatives

```ruby
rake truncato:vendor_compare
```

The results comparing truncato with other libs:

<table>
  <tr>
    <th></th>
    <th>Truncato</th>
    <th><a href="https://github.com/ianwhite/truncate_html">truncate_html</a></th>
    <th><a href="https://github.com/nono/HTML-Truncator">HTML Truncator</a></th>
  </tr>
  <tr>
    <th>Time for truncating a 4MB XML document to 4KB</th>
    <td>1.5 s</td>
    <td>20 s</td>
    <td>220 s</td>
  </tr>
</table>

# Running the tests

```ruby
rake spec
```


