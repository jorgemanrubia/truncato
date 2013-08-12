require "spec_helper"

describe "Truncato" do
  describe "normal strings" do
    #it_should_truncate "no html text with longer length", with: {max_length: 13, tail: '...'}, source: "some text", expected: "some text"
    #it_should_truncate "no html text with shorter length", with: {max_length: 3}, source: "some text", expected: "som..."
    it_should_truncate "no html text with longer length", with: {max_length: 4}, source: "some", expected: "some"
  end

  describe "html tags structure" do
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

    it_should_truncate "html text with siblings tags", with: {max_length: 51},
                       source: "<div>some text 0</div><div><p>some text 1</p><p>some text 2</p></div>",
                       expected: "<div>some text 0</div><div><p>some text 1</p><p>som...</p></div>"

    it_should_truncate "htlm with unclosed tags", with: {max_length: 151},
                       source: "<table><tr><td>Hi <br> there</td></tr></table>",
                       expected: "<table><tr><td>Hi <br/> there</td></tr></table>"
  end

  describe "include tail as part of max_length" do
    it_should_truncate "html text with a tag (counting tail)", with: {max_length: 4, count_tail: true, count_tags: false},
                        source: "<p>some text</p>",
                        expected: "<p>s...</p>"

    it_should_truncate "html text with a tag (counting tail)", with: {max_length: 6, count_tail: true, count_tags: false}, source: "<p>some text</p>", expected: "<p>som...</p>"

    it_should_truncate "html text with a tag (counting tail)", with: {max_length: 16, count_tail: true, count_tags: false},
                        source: "<p>some text</p><div><span>some other text</span></div>",
                        expected: "<p>some text</p><div><span>some...</span></div>"

    it_should_truncate "html text with a tag (counting tail and including tail before final tag)", with: {max_length: 16, count_tail: true, count_tags: false, tail_before_final_tag: true},
                        source: "<p>some text</p><div><span>some other text</span></div>",
                        expected: "<p>some text</p><div><span>some</span>...</div>"

    it_should_truncate "html text, counting special html characters as one character",
                        with: {max_length: 16, count_tail: true, count_tags: false, tail_before_final_tag: true, tail: '&hellip;'},
                        source: "<p>some text</p><div><span>some other text</span></div>",
                        expected: "<p>some text</p><div><span>some o</span>&hellip;</div>"
  end

  describe "insert tail between two or more final tags" do
    it_should_truncate "html text as normal when tail_before_final_tag option is not set",
                        with: {max_length: 4, count_tags: false},
                        source: "<p><span>some text</span>some more text</p>",
                        expected: "<p><span>some...</span></p>"

    it_should_truncate "html text when tail_before_final_tag: true by inserting tail before the final tag, and after any other closing tags",
                        with: {max_length: 4, count_tags: false, tail_before_final_tag: true},
                        source: "<p><span>some text</span>some more text</p>",
                        expected: "<p><span>some</span>...</p>"
  end

  describe "single html tag elements" do
    it_should_truncate "html text with <br /> element without adding a closing tag", with: {max_length: 9},
                       source: "<div><p><br />some text 1</p><p>some text 2</p></div>",
                       expected: "<div><p><br />...</p></div>"

    it_should_truncate "html text with <img /> element without adding a closing tag", with: {max_length: 9},
                       source: "<div><p><img src='some_path' />some text 1</p><p>some text 2</p></div>",
                       expected: "<div><p><img src='some_path' />...</p></div>"
  end

  describe "comment html element" do
    it_should_truncate "html text and ignore <!-- a comment --> element by default", with: {max_length: 20},
                       source: "<!-- a comment --><p>some text 1</p>",
                       expected: "<p>some text 1</p>"

    it_should_truncate "html text with <!-- a comment --> element", with: {max_length: 30, comments: true},
                       source: "<!-- a comment --><p>some text 1</p>",
                       expected: "<!-- a comment --><p>some text...</p>"

    it_should_truncate "html text with <!-- a comment --> element that exceeds the max_length", with: {max_length: 5, comments: true},
                       source: "<!-- a comment --><p>some text 1</p>",
                       expected: "<!-- ...-->"

    it_should_truncate "html text with <!-- a comment --> element with other elements that exceeds max_length", with: {max_length: 20, comments: true},
                       source: "<!-- a comment --><p>some text 1</p>",
                       expected: "<!-- a comment --><p>...</p>"
  end

  describe "html attributes" do
    it_should_truncate "html text with 1 attributes", with: {max_length: 3, count_tags: false},
                       source: "<p attr1='1'>some text</p>",
                       expected: "<p attr1='1'>som...</p>"

    it_should_truncate "html text with 1 attributes counting its size", with: {max_length: 16, count_tags: true},
                       source: "<p attr1='1'>some text</p>",
                       expected: "<p attr1='1'>som...</p>"

    it_should_truncate "html text with 2 attributes", with: {max_length: 3, count_tags: false},
                       source: "<p attr1='1' attr2='2'>some text</p>",
                       expected: "<p attr1='1' attr2='2'>som...</p>"

    it_should_truncate "html text with attributes in nested tags", with: {max_length: 4, count_tags: false},
                       source: "<div><p attr1='1'>some text</p></div>",
                       expected: "<div><p attr1='1'>some...</p></div>"

    it_should_truncate "html text with attribute containing entities respecting them", with: {max_length: 3, count_tags: false, filtered_attributes: ['attr2']},
                       source: "<p attr1='&gt;some'>text</p>",
                       expected: "<p attr1='&gt;some'>tex...</p>"

    it_should_truncate "html text with 2 attributes filtering one of them", with: {max_length: 90, count_tags: false, filtered_attributes: ['attr2']},
                       source: "<p attr1='1'>some text</p><p attr2='2'>filtered text</p>",
                       expected: "<p attr1='1'>some text</p><p>filtered text</p>"

    it_should_truncate "html text with 2 attributes filtering all of them", with: {max_length: 3, count_tags: false, filtered_attributes: ['attr1', 'attr2']},
                       source: "<p attr1='1' attr2='2'>some text</p>",
                       expected: "<p>som...</p>"
  end

end
