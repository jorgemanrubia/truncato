require "spec_helper"

describe "Truncato" do
  describe "normal strings" do
    it_should_truncate "no html text with longer length", with: {max_length: 13, tail: '...'}, source: "some text", expected: "some text"
    it_should_truncate "no html text with shorter length", with: {max_length: 3}, source: "some text", expected: "som..."
    it_should_truncate "no html text with longer length", with: {max_length: 4}, source: "some", expected: "some"
  end

  describe "html strings" do
    it_should_truncate "html text with a tag (counting tags)", with: {max_length: 4}, source: "<p>some text</p>", expected: "<p>s...</p>"

    it_should_truncate "html text with a tag (not counting tags)", with: {max_length: 4, count_tags: false}, source: "<p>some text</p>", expected: "<p>some...</p>"

    it_should_truncate "html text with nested tags (first node)", with: {max_length: 9},
                       source: "<div><p>some text 1</p><p>some text 2</p></div>",
                       expected: "<div><p>s...</p></div>"

    it_should_truncate "html text with nested tags (second node)", with: {max_length: 33},
                       source: "<div><p>some text 1</p><p>some text 2</p></div>",
                       expected: "<div><p>some text 1</p><p>some te...</p></div>"

    it_should_truncate "html text with nested tags (empty contents)", with: {max_length: 3},
                       source: "<div><p>some text 1</p><p>some text 2</p></div>",
                       expected: "<div>...</div>"

    it_should_truncate "html text with special html entioes", with: {max_length: 5},
                       source: "<p>&gt;some text</p>",
                       expected: "<p>&gt;s...</p>"
  end

end

