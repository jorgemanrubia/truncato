class TruncatedSaxDocument < Nokogiri::XML::SAX::Document
  attr_reader :truncated_string, :max_length, :max_length_reached, :tail

  def initialize(max_length, tail)
    @truncated_string = ""
    @closing_tags = []
    @max_length = max_length
    @estimated_length = 0
    @tail = tail
    @max_length_reached = false
  end

  def start_element name, attributes
    return if @max_length_reached
    @closing_tags.unshift name
    append_to_truncated_string opening_tag(name)
  end

  def characters string
    puts string
    return if @max_length_reached
    remaining_length = max_length - @estimated_length
    string = truncate_string(string, remaining_length) if string.length > remaining_length
    append_to_truncated_string string
  end

  def end_element name
    return if @max_length_reached
    increase_estimated_length name.length + 3
    @closing_tags.pop
    append_to_truncated_string closing_tag(name)
  end

  def end_document
    append_closing_tags if max_length_reached
  end

  private

  def append_to_truncated_string(string)
    @truncated_string << string
    increase_estimated_length string.length
  end

  def opening_tag name
    "<#{name}>"
  end

  def closing_tag name
    "</#{name}>"
  end

  def increase_estimated_length amount
    @estimated_length += amount
    check_max_length_reached
  end

  def check_max_length_reached
    @check_max_length_reached = true if @estimated_length >= max_length
  end

  def truncate_string string, remaining_length
    "#{string[0..remaining_length]}#{tail}"
  end

  def append_closing_tags
    @closing_tags.reverse.each { |name| append_to_truncated_string closing_tag(name) }
  end
end