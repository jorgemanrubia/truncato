module Truncato
  DEFAULT_CHARACTER_OPTIONS = {
      max_length: 30,
      count_tags: true,
      tail: "...",
      filtered_attributes: []
  }

  DEFAULT_BYTESIZE_OPTIONS = DEFAULT_CHARACTER_OPTIONS.merge({ count_tail: true })

  ARTIFICIAL_ROOT_NAME = '__truncato_root__'

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
    options = user_options[:max_bytes] ? DEFAULT_BYTESIZE_OPTIONS.merge(user_options) : DEFAULT_CHARACTER_OPTIONS.merge(user_options)
    self.do_truncate_html(source, options) ? self.do_truncate_html(with_artificial_root(source), options) : nil
  end

  private

  def self.do_truncate_html source, options
    truncated_sax_document = TruncatedSaxDocument.new(options)
    parser = Nokogiri::HTML::SAX::Parser.new(truncated_sax_document)
    parser.parse(source) { |context| context.replace_entities = false }
    truncated_string = truncated_sax_document.truncated_string
    truncated_string.empty? ? nil : truncated_string
  end

  def self.with_artificial_root(source)
    "<#{ARTIFICIAL_ROOT_NAME}>#{source}</#{ARTIFICIAL_ROOT_NAME}>"
  end
end
