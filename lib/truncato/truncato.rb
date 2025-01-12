module Truncato
  DEFAULT_OPTIONS = {
      max_length: 30,
      count_tags: true,
      tail: "...",
      filtered_attributes: []
  }

  ARTIFICIAL_ROOT_NAME = 'truncato-artificial-root'

  # Truncates the source XML string and returns the truncated XML. It will keep a valid XML structure
  # and insert a _tail_ text indicating the position where content were removed (...).
  #
  # @param [String] source the XML source to truncate
  # @param [Hash] user_options truncation options
  # @option user_options [Integer] :max_length Maximum length
  # @option user_options [String] :tail text to append when the truncation happens
  # @option user_options [Boolean] :count_tags `true` for counting tags for truncation, `false` for not counting them
  # @option user_options [Array<String>] :filtered_attributes Array of names of attributes that should be excluded in the resulting truncated string. This allows you to make the truncated string shorter by excluding the content of attributes you can discard in some given context, e.g HTML `style` attribute.
  # @return [String] the truncated string
  def self.truncate source, user_options={}
    options = DEFAULT_OPTIONS.merge(user_options)
    self.truncate_html(source, options) || self.truncate_no_html(source, options)
  end

  private

  def self.truncate_html source, options
    self.do_truncate_html(source, options) ? self.do_truncate_html(with_artificial_root(source), options) : nil
  end

  def self.do_truncate_html source, options
    begin
      source = source.unicode_normalize
    rescue Encoding::CompatibilityError
      # Only Unicode encodings can be normalized.
      #
      # Ruby docs:
      # > In this context, 'Unicode Encoding' means any of UTF-8,
      # > UTF-16BE/LE, and UTF-32BE/LE, as well as GB18030, UCS_2BE, and
      # > UCS_4BE. Anything else than UTF-8 is implemented by converting
      # > to UTF-8, which makes it slower than UTF-8.
    end

    truncated_sax_document = TruncatedSaxDocument.new(options)

    # Only nokogiri >= 1.17 accept Encoding object, older needs a String as encoding
    parser = Nokogiri::HTML::SAX::Parser.new(truncated_sax_document, source.encoding.to_s)
    parser.parse(source) { |context| context.replace_entities = false }
    truncated_string = truncated_sax_document.truncated_string
    truncated_string.empty? ? nil : truncated_string
  end

  def self.with_artificial_root(source)
    "<#{ARTIFICIAL_ROOT_NAME}>#{source}</#{ARTIFICIAL_ROOT_NAME}>"
  end

  def self.truncate_no_html source, options
    max_length = options[:max_length]
    tail = source.length > max_length ? options[:tail] : ''
    "#{source[0..max_length-1]}#{tail}"
  end
end
