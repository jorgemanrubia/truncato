module Truncato
  class BenchmarkRunner
    SYNTHETIC_XML_LENGTH = 4000000
    TRUNCATION_LENGTH = 400000

    attr_reader :synthetic_xml

    def initialize
      @synthetic_xml = create_synthetic_xml(SYNTHETIC_XML_LENGTH)
      puts "Generated synthethic load with #{@synthetic_xml.length/1000.0}K characters"
    end

    def run
      run_suite [Truncato]
    end

    def run_comparison
      run_suite [Truncato, VendorHtmlTruncatorAdapter]
    end

    private

    def run_suite(truncation_classes)
      results = truncation_classes.collect { |klass| {klass => run_with(klass)} }
      show_results results
    end

    def create_synthetic_xml(length)
      xml_content = "<synthetic-root>"
      append_random_xml_content xml_content, length
      xml_content << "</synthetic-root>"
      xml_content
    end

    def append_random_xml_content(xml_content, length)
      begin
        random_tag = random_string(rand(10)+1)
        xml_content << %{
          <#{random_tag}>#{random_string(rand(300)+1)}</#{random_tag}>
        }
      end while (xml_content.length < length)
    end

    def random_string(length)
      (0...length).map { 65.+(rand(26)).chr }.join
    end

    def run_with(truncation_klass)
      puts "Running benchmark for #{truncation_klass}..."
      truncated_string = ""
      result = Benchmark.measure { truncated_string = truncation_klass.truncate synthetic_xml, max_length: TRUNCATION_LENGTH, count_tags: true }
      {truncated_length: truncated_string.length, time: result.total}
    end

    def show_results(results)
      puts results.inspect
    end

  end
end