module Truncato
  class BenchmarkRunner
    attr_reader :synthetic_xml

    SYNTHETIC_XML_LENGTH = 4000000
    TRUNCATION_LENGTH = 400000

    def run
      @synthetic_xml = create_synthetic_xml(SYNTHETIC_XML_LENGTH)
      puts "Generated synthethic load with #{@synthetic_xml.length/1000.0}K characters"
      results = [Truncato].collect { |klass| {klass => run_with(klass)} }
      show_results results
    end

    private

    def create_synthetic_xml(length)
      xml_content = "<synthetic-root>"
      append_random_xml_content(xml_content, length)
      xml_content << "</synthetic-root>"
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
      truncated_string = ""
      result = Benchmark.measure { truncated_string = truncation_klass.truncate synthetic_xml, max_length: TRUNCATION_LENGTH }
      {truncated_length: truncated_string.length, time: result.total}
    end

    def show_results(results)
      puts results.inspect
    end

  end
end