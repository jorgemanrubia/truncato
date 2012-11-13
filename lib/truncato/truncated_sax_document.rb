class TruncatedSaxDocument < Nokogiri::XML::SAX::Document
  attr_reader :truncated_string, :max_length, :max_length_reached, :tail, :count_tags, :filtered_attributes

  def initialize(options)
    @html_coder = HTMLEntities.new
    capture_options(options)
    init_parsing_state
  end

  def start_element name, attributes
    return if @max_length_reached
    @closing_tags.push name
    append_to_truncated_string opening_tag(name, attributes), overriden_tag_length
  end

  def characters decoded_string
    return if @max_length_reached
    remaining_length = max_length - @estimated_length - 1
    string_to_append = decoded_string.length > remaining_length ? truncate_string(decoded_string, remaining_length) : decoded_string
    append_to_truncated_string @html_coder.encode(string_to_append), string_to_append.length
  end

  def end_element name
    return if @max_length_reached
    @closing_tags.pop
    append_to_truncated_string closing_tag(name), overriden_tag_length
  end

  def end_document
    close_truncated_document if max_length_reached
  end

  private

  def capture_options(options)
    @max_length = options[:max_length]
    @count_tags = options [:count_tags]
    @tail = options[:tail]
    @filtered_attributes = options[:filtered_attributes] || []
  end

  def init_parsing_state
    @truncated_string = ""
    @closing_tags = []
    @estimated_length = 0
    @max_length_reached = false
  end

  def append_to_truncated_string string, overriden_length=nil
    @truncated_string << string
    increase_estimated_length(overriden_length || string.length)
  end

  def opening_tag name, attributes
    attributes_string = attributes_to_string(attributes)
    "<#{name}#{attributes_string}>"
  end

  def attributes_to_string(attributes)
    return "" if attributes.empty?
    attributes_string = concatenate_attributes_declaration attributes
    attributes_string.rstrip
  end

  def concatenate_attributes_declaration(attributes)
    attributes.inject(' ') do |string, attribute|
      key, value = attribute
      next string if @filtered_attributes.include?(key)
      string << "#{key}='#{@html_coder.encode(value)}' "
    end
  end

  def closing_tag name
    "</#{name}>"
  end

  def increase_estimated_length amount
    @estimated_length += amount
    check_max_length_reached
  end

  def check_max_length_reached
    @max_length_reached = true if @estimated_length >= max_length
  end

  def truncate_string string, remaining_length
    @tail_appended = true
    "#{string[0..remaining_length]}#{tail}"
  end

  def close_truncated_document
    append_to_truncated_string tail unless @tail_appended
    append_closing_tags
  end

  def append_closing_tags
    @closing_tags.reverse.each { |name| append_to_truncated_string closing_tag(name) }
  end

  def overriden_tag_length
    @count_tags ? nil : 0
  end
end