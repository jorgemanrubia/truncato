module TruncatoMacros
  def it_should_truncate(example_description, options)
    it "should truncate #{example_description}" do
      expected_options = Truncato::DEFAULT_OPTIONS.merge(options[:with])
      Truncato.truncate(options[:source], expected_options).should == options[:expected]
    end
  end
end