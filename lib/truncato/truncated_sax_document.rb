require 'nokogiri'
require 'htmlentities'

class TruncatedSaxDocument < Nokogiri::XML::SAX::Document
  IGNORABLE_TAGS = %w(html head body)

  # These don't have to be closed (which also impacts ongoing length calculations)
  SINGLE_TAGS = %w{br img}

  attr_reader :truncated_string, :max_length, :max_bytes, :max_length_reached, :tail,
              :count_tags, :filtered_attributes, :filtered_tags, :ignored_levels, :something_has_been_truncated

  def initialize(options)
    @html_coder = HTMLEntities.new
    capture_options options
    init_parsing_state
  end

  def start_element name, attributes
    enter_ignored_level if filtered_tags.include?(name)
    return if @max_length_reached || ignorable_tag?(name) || ignore_mode?

    string_to_add = opening_tag(name, attributes)

    # Abort if there is not enough space to add the combined opening tag and (potentially) the closing tag
    length = overriden_tag_length(name, string_to_add)
    return if length > remaining_length

    # Save the tag so we can push it on at the end
    @closing_tags.push name unless single_tag_element? name

    append_to_truncated_string string_to_add, length
  end

  def characters decoded_string
    if @max_length_reached || ignore_mode?
      @something_has_been_truncated |= @max_length_reached
      return
    end
    if max_bytes
      # Use encoded length, so &gt; counts as 4 bytes, not 1 (which is what '>' would give)
      string_to_append = if char_or_byte_count(@html_coder.encode(decoded_string)) > remaining_length
        @something_has_been_truncated = true
        truncate_string(decoded_string, remaining_length)
      else
        decoded_string
      end
      encoded_string_to_append = @html_coder.encode(string_to_append)
      length = char_or_byte_count(encoded_string_to_append)
    else
      string_to_append = if char_or_byte_count(decoded_string) > remaining_length
        @something_has_been_truncated = true
        truncate_string(decoded_string, remaining_length)
      else
        decoded_string
      end
      encoded_string_to_append = @html_coder.encode(string_to_append)
      length = char_or_byte_count(string_to_append)
    end

    append_to_truncated_string encoded_string_to_append, length
  end

  def comment string
    if @comments
      return if @max_length_reached
      process_comment string
    end
  end

  def end_element name
    if filtered_tags.include?(name) && ignore_mode?
      exit_ignored_level
      return
    end

    return if @max_length_reached || ignorable_tag?(name) || ignore_mode?

    unless single_tag_element? name
      @closing_tags.pop
      # Don't count the length when closing a tag - it was accomodated when
      # the tag was opened
      append_to_truncated_string closing_tag(name), 0
    end
  end

  def end_document
    close_truncated_document if max_length_reached
  end

  private

  def remaining_length
    maximum - estimated_length_with_tail
  end

  def estimated_length_with_tail
    @estimated_length + ((@count_tail && @something_has_been_truncated)? tail_length : 0)
  end

  def capture_options(options)
    @max_length = options[:max_length]
    @max_bytes = options[:max_bytes]
    @count_tags = options [:count_tags]
    @count_tail = options.fetch(:count_tail, false)
    @tail = options[:tail]
    @filtered_attributes = options[:filtered_attributes] || []
    @filtered_tags = options[:filtered_tags] || []
    @tail_before_final_tag = options.fetch(:tail_before_final_tag, false)
    @comments = options.fetch(:comments, false)

    raise(ArgumentError, "Cannot specify `max_bytes` if `count_tags` is not true") if @max_bytes && !@count_tags
    raise(ArgumentError, "Cannot specify `max_bytes` if `count_tail` is not true") if @max_bytes && !@count_tail #&& !@tail.empty?
  end

  def process_comment(string)
    string_to_append = if char_or_byte_count(comment_tag(string)) > remaining_length
      truncate_comment(comment_tag(string), remaining_length)
    else
      comment_tag(string)
    end
    append_to_truncated_string string_to_append
  end

  def comment_tag comment
    "<!--#{comment}-->"
  end

  def init_parsing_state
    @truncated_string = ""
    @closing_tags = []
    @estimated_length = 0
    @max_length_reached = false
    @ignored_levels = 0
  end

  def tail_length
    tail.match(/^&\w+;$/).nil? ? char_or_byte_count(tail) : 1
  end

  def single_tag_element? name
    SINGLE_TAGS.include? name
  end

  def append_to_truncated_string string, overriden_length=nil
    @truncated_string << string
    increase_estimated_length(overriden_length || char_or_byte_count(string))
  end

  def opening_tag name, attributes
    attributes_string = attributes_to_string attributes
    if single_tag_element? name
      "<#{name}#{attributes_string}/>"
    else
      "<#{name}#{attributes_string}>"
    end
  end

  def attributes_to_string attributes
    return "" if attributes.empty?
    attributes_string = concatenate_attributes_declaration attributes
    attributes_string.rstrip
  end

  def concatenate_attributes_declaration attributes
    attributes.inject(' ') do |string, attribute|
      key, value = attribute
      next string if @filtered_attributes.include? key
      string << "#{key}='#{@html_coder.encode value}' "
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
    @max_length_reached = true if estimated_length_with_tail >= maximum
  end

  def truncate_string string, remaining_length
    @something_has_been_truncated = true
    if @tail_before_final_tag
      @max_bytes ? "#{string.byteslice(0, remaining_length).scrub('')}" : "#{string.slice(0, remaining_length)}"
    else
      @tail_appended = true
      @max_bytes ? "#{string.byteslice(0, remaining_length).scrub('')}#{tail}" : "#{string.slice(0, remaining_length)}#{tail}"
    end
  end

  def truncate_comment string, remaining_length
    remaining_length_for_start_of_comment = remaining_length - tail_length - char_or_byte_count("-->")

    if @tail_before_final_tag
      string.slice(0, remaining_length_for_start_of_comment)
    else
      @tail_appended = true
      "#{string.slice(0, remaining_length_for_start_of_comment)}#{tail}-->"
    end
  end

  def close_truncated_document
    append_tail_between_closing_tags if @tail_before_final_tag

    # Only add the tail if something has been truncated and we haven't already added it
    if @something_has_been_truncated && !@tail_appended
      append_to_truncated_string tail
    end
    append_closing_tags
  end

  def append_closing_tags
    @closing_tags.reverse.each { |name| append_to_truncated_string closing_tag name }
  end

  def overriden_tag_length(tag_name, rendered_tag_with_attributes)
    return 0 unless @count_tags

    # Start with the opening tag
    length = char_or_byte_count(rendered_tag_with_attributes)

    # Add on closing tag if necessary
    length += char_or_byte_count(closing_tag(tag_name)) unless single_tag_element?(tag_name)
    length
  end

  def ignorable_tag?(name)
    artificial_root_name?(name) || IGNORABLE_TAGS.include?(name.downcase)
  end

  def artificial_root_name? name
    name == Truncato::ARTIFICIAL_ROOT_NAME
  end

  def append_tail_between_closing_tags
    append_to_truncated_string closing_tag(@closing_tags.delete_at (@closing_tags.size - 1)) if @closing_tags.any?
  end

  def enter_ignored_level
    @ignored_levels += 1
  end

  def exit_ignored_level
    @ignored_levels -= 1
  end

  def ignore_mode?
    @ignored_levels > 0
  end

  def char_or_byte_count(str)
    @max_bytes ? str.bytesize : str.length
  end

  def maximum
    max_bytes || max_length
  end
end
