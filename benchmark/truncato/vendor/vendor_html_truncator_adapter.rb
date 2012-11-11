module Truncato
  class VendorHtmlTruncatorAdapter
    def self.truncate string, options
      HTML_Truncator.truncate string, options[:max_length], ellipsis: "..."
    end
  end
end

#[{Truncato::VendorHtmlTruncatorAdapter=>{:truncated_length=>3584682, :time=>223.36}}]

