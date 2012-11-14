# Adapter for comparing https://github.com/nono/HTML-Truncator
module Truncato
  class PeppercornAdapter
    def self.truncate string, options
      string.truncate_html options[:max_length], :tail=>options[:tail]
    end
  end
end

