module Truncato
  DEFAULT_OPTIONS = {
      max_length: 30,
      tail: "..."
  }

  def self.truncate source, user_options={}
    options = DEFAULT_OPTIONS.merge(user_options)
    self.truncate_html(source, options) || self.truncate_no_html(source, options)
  end

  private

  def self.truncate_html source, options
    truncated_sax_document = TruncatedSaxDocument.new(options[:max_length], options[:tail])
    parser = Nokogiri::XML::SAX::Parser.new(truncated_sax_document)
    parser.parse(source){|context| context.replace_entities = false}
    truncated_string = truncated_sax_document.truncated_string
    truncated_string.empty? ? nil : truncated_string
  end

  def self.truncate_no_html source, options
    max_length = options[:max_length]
    tail = source.length > max_length ? options[:tail] : ''
    "#{source[0..max_length-1]}#{tail}"
  end
end