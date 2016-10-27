module TruncatoMacros
  def it_should_truncate_characters(example_description, options)
    it "should truncate #{example_description}" do
      expected_options = Truncato::DEFAULT_CHARACTER_OPTIONS.merge(options[:with])
      result = Truncato.truncate(options[:source], expected_options)
      result.should == options[:expected]
      if expected_options[:count_tags] && expected_options[:count_tail]
        result.length.should <= expected_options[:max_length]
      end
    end
  end

  def it_should_truncate_bytes(example_description, options)
    it "should truncate #{example_description}" do
      expected_options = Truncato::DEFAULT_BYTESIZE_OPTIONS.merge(options[:with])
      result = Truncato.truncate(options[:source], expected_options)
      result.should == options[:expected]
      result.bytesize.should <= expected_options[:max_bytes]
    end
  end
end
