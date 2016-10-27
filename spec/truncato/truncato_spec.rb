require "spec_helper"
require "byebug"
require "awesome_print"


describe "Truncato" do
  NBSP = Nokogiri::HTML("&nbsp;").text

  context "truncating by character count" do
    describe "normal strings" do
      context "with tail" do
        it_should_truncate_characters "no html text with longer length", with: {max_length: 13}, source: "some text", expected: "some text"
        it_should_truncate_characters "no html text with equal length", with: {max_length: 9}, source: "some text", expected: "some text"
        it_should_truncate_characters "no html text with shorter length", with: {max_length: 3}, source: "some text", expected: "som..."
      end
      context "without tail" do
        it_should_truncate_characters "no html text with longer length", with: {max_length: 13, tail: ""}, source: "some text", expected: "some text"
        it_should_truncate_characters "no html text with equal length", with: {max_length: 9, tail: ""}, source: "some text", expected: "some text"
        it_should_truncate_characters "no html text with shorter length", with: {max_length: 3, tail: ""}, source: "some text", expected: "som"
      end
    end

    describe "html tags structure" do
      it_should_truncate_characters "html text with a tag (counting tags)", with: {max_length: 15}, source: "<p>some text</p>", expected: "<p>some tex...</p>"

      it_should_truncate_characters "html text with a tag (not counting tags)", with: {max_length: 4, count_tags: false}, source: "<p>some text</p>", expected: "<p>some...</p>"

      it_should_truncate_characters "html text with nested tags (first node)", with: {max_length: 19},
                         source: "<div><p>some text 1</p><p>some text 2</p></div>",
                         expected: "<div><p>s...</p></div>"

      it_should_truncate_characters "html text with nested tags (second node)", with: {max_length: 43},
                         source: "<div><p>some text 1</p><p>some text 2</p></div>",
                         expected: "<div><p>some text 1</p><p>some te...</p></div>"

      it_should_truncate_characters "html text with nested tags (empty contents)", with: {max_length: 11},
                         source: "<div><p>some text 1</p><p>some text 2</p></div>",
                         expected: "<div>...</div>"

      it_should_truncate_characters "html text with nested tags (empty contents)", with: {max_length: 14, count_tail: true},
                         source: "<div><p>some text 1</p><p>some text 2</p></div>",
                         expected: "<div>...</div>"

      it_should_truncate_characters "html text with special html entities", with: {max_length: 9},
                         source: "<p>&gt;some text</p>",
                         expected: "<p>&gt;s...</p>"

      it_should_truncate_characters "html text with siblings tags", with: {max_length: 61},
                         source: "<div>some text 0</div><div><p>some text 1</p><p>some text 2</p></div>",
                         expected: "<div>some text 0</div><div><p>some text 1</p><p>som...</p></div>"

      it_should_truncate_characters "html with unclosed tags", with: {max_length: 151},
                         source: "<table><tr><td>Hi <br> there</td></tr></table>",
                         expected: "<table><tr><td>Hi <br/> there</td></tr></table>"

      it_should_truncate_characters "sdasd", with: {},
                         source: "<span>Foo&nbsp;Bar</span>", expected: "<span>Foo#{NBSP}Bar</span>"
    end

    describe "include tail as part of max_length" do
      it_should_truncate_characters "html text with a tag (counting tail)", with: {max_length: 4, count_tail: true, count_tags: false},
                          source: "<p>some text</p>",
                          expected: "<p>s...</p>"

      it_should_truncate_characters "html text with a tag (counting tail)", with: {max_length: 6, count_tail: true, count_tags: false}, source: "<p>some text</p>", expected: "<p>som...</p>"

      it_should_truncate_characters "html text with a tag (counting tail)", with: {max_length: 16, count_tail: true, count_tags: false},
                          source: "<p>some text</p><div><span>some other text</span></div>",
                          expected: "<p>some text</p><div><span>some...</span></div>"

      it_should_truncate_characters "html text with a tag (counting tail and including tail before final tag)", with: {max_length: 16, count_tail: true, count_tags: false, tail_before_final_tag: true},
                          source: "<p>some text</p><div><span>some other text</span></div>",
                          expected: "<p>some text</p><div><span>some</span>...</div>"

      it_should_truncate_characters "html text, counting special html characters as one character",
                          with: {max_length: 16, count_tail: true, count_tags: false, tail_before_final_tag: true, tail: '&hellip;'},
                          source: "<p>some text</p><div><span>some other text</span></div>",
                          expected: "<p>some text</p><div><span>some o</span>&hellip;</div>"
    end

    describe "insert tail between two or more final tags" do
      it_should_truncate_characters "html text as normal when tail_before_final_tag option is not set",
                          with: {max_length: 4, count_tags: false},
                          source: "<p><span>some text</span>some more text</p>",
                          expected: "<p><span>some...</span></p>"

      it_should_truncate_characters "html text when tail_before_final_tag: true by inserting tail before the final tag, and after any other closing tags",
                          with: {max_length: 4, count_tags: false, tail_before_final_tag: true},
                          source: "<p><span>some text</span>some more text</p>",
                          expected: "<p><span>some</span>...</p>"
    end

    describe "single html tag elements" do
      it_should_truncate_characters "html text with <br /> element without adding a closing tag", with: {max_length: 2, count_tags: false},
                         source: "<div><h1><br/>some text 1</h1><p>some text 2</p></div>",
                         expected: "<div><h1><br/>so...</h1></div>"

      it_should_truncate_characters "html text with <img/> element without adding a closing tag", with: {max_length: 2, count_tags: false},
                         source: "<div><p><img src='some_path'/>some text 1</p><p>some text 2</p></div>",
                         expected: "<div><p><img src='some_path'/>so...</p></div>"
    end

    describe "comment html element" do
      it_should_truncate_characters "html text and ignore <!-- a comment --> element by default", with: {max_length: 18},
                         source: "<!-- a comment --><p>some text 1</p>",
                         expected: "<p>some text 1</p>"

      it_should_truncate_characters "html text with <!-- a comment --> element", with: {max_length: 34, comments: true},
                         source: "<!-- a comment --><p>some text 1</p>",
                         expected: "<!-- a comment --><p>some text...</p>"

      it_should_truncate_characters "html text with <!-- a comment --> element that exceeds the max_length", with: {max_length: 11, comments: true},
                         source: "<!-- a comment --><p>some text 1</p>",
                         expected: "<!-- ...-->"

      it_should_truncate_characters "html text with <!-- a comment --> element with other elements that exceeds max_length", with: {max_length: 25, comments: true},
                         source: "<!-- a comment --><p>some text 1</p>",
                         expected: "<!-- a comment --><p>...</p>"
    end

    describe "html attributes" do
      it_should_truncate_characters "html text with 1 attributes", with: {max_length: 3, count_tags: false},
                         source: "<p attr1='1'>some text</p>",
                         expected: "<p attr1='1'>som...</p>"

      it_should_truncate_characters "html text with 1 attributes counting its size", with: {max_length: 20, count_tags: true},
                         source: "<p attr1='1'>some text</p>",
                         expected: "<p attr1='1'>som...</p>"

      it_should_truncate_characters "html text with 2 attributes", with: {max_length: 3, count_tags: false},
                         source: "<p attr1='1' attr2='2'>some text</p>",
                         expected: "<p attr1='1' attr2='2'>som...</p>"

      it_should_truncate_characters "html text with attributes in nested tags", with: {max_length: 4, count_tags: false},
                         source: "<div><p attr1='1'>some text</p></div>",
                         expected: "<div><p attr1='1'>some...</p></div>"

      it_should_truncate_characters "html text with attribute containing entities respecting them", with: {max_length: 3, count_tags: false, filtered_attributes: ['attr2']},
                         source: "<p attr1='&gt;some'>text</p>",
                         expected: "<p attr1='&gt;some'>tex...</p>"

      it_should_truncate_characters "html text with 2 attributes filtering one of them", with: {max_length: 90, count_tags: false, filtered_attributes: ['attr2']},
                         source: "<p attr1='1'>some text</p><p attr2='2'>filtered text</p>",
                         expected: "<p attr1='1'>some text</p><p>filtered text</p>"

      it_should_truncate_characters "html text with 2 attributes filtering all of them", with: {max_length: 3, count_tags: false, filtered_attributes: ['attr1', 'attr2']},
                         source: "<p attr1='1' attr2='2'>some text</p>",
                         expected: "<p>som...</p>"
    end

    describe "excluded tags" do
      it_should_truncate_characters "html text with a filtered tag", with: {max_length: 90, filtered_tags: %w(img)},
                         source: "<p><img/>some text</p>",
                         expected: "<p>some text</p>"

      it_should_truncate_characters "html text with a filtered tag with nested tags", with: {max_length: 90, filtered_tags: %w(table img)},
                         source: "<div><table><tr>Hi there</tr></table>some text<img/></div>",
                         expected: "<div>some text</div>"

      it_should_truncate_characters "html text with a filtered tag with nested tags where nested tags are filtered", with: {max_length: 90, filtered_tags: %w(table tr img)},
                         source: "<div><table><tr><td>Hi there</td></tr></table>some text<img/></div>",
                         expected: "<div>some text</div>"
    end
  end

  context "truncating by bytesize" do
    it "enforces `count_tags` being enabled" do
      options = Truncato::DEFAULT_CHARACTER_OPTIONS.merge({max_bytes: 14, count_tags: false})
      expect{ Truncato.truncate("<p>some text</p>", options) }.to raise_error(ArgumentError)
    end

    it "enforces `count_tail` being enabled" do
      options = Truncato::DEFAULT_CHARACTER_OPTIONS.merge({max_bytes: 14, count_tail: false, tail: "..."})
      expect{ Truncato.truncate("<p>some text</p>", options) }.to raise_error(ArgumentError)
    end

    describe "normal strings" do
      it_should_truncate_bytes "no html text with longer length", with: {max_bytes: 13}, source: "some text", expected: "some text"
      it_should_truncate_bytes "no html text with shorter length, no tail", with: {max_bytes: 7, tail: ""}, source: "some text", expected: "some te"
      it_should_truncate_bytes "no html text with shorter length, with tail", with: {max_bytes: 7}, source: "some text", expected: "some..."
    end

    describe "multi-byte strings" do
      # These examples purposely specify a number of bytes which is not divisible by four, to ensure
      # characters don't get brokwn up part-way thorugh their multi-byte representation
      it_should_truncate_bytes "no html text with longer length", with: {max_bytes: 51, tail: '...'}, source: "𠲖𠲖𠲖𠲖𠲖𠲖𠲖𠲖", expected: "𠲖𠲖𠲖𠲖𠲖𠲖𠲖𠲖"
      it_should_truncate_bytes "no html text with shorter length, no tail", with: {max_bytes: 7, tail: ''}, source: "𠝹𠝹𠝹𠝹𠝹𠝹𠝹𠝹", expected: "𠝹"
      it_should_truncate_bytes "no html text with shorter length, with tail", with: {max_bytes: 7}, source: "𠝹𠝹", expected: "𠝹..."
    end

    describe "multi-byte tail" do
    end

    describe "html tags structure" do
      it_should_truncate_bytes "html text with tag", with: {max_bytes: 14}, source: "<p>some text</p>", expected: "<p>some...</p>"

      it_should_truncate_bytes "html text with nested tags (first node)", with: {max_bytes: 22},
                         source: "<div><p>some text 1</p><p>some text 2</p></div>",
                         expected: "<div><p>s...</p></div>"

      it_should_truncate_bytes "html text with nested tags (second node)", with: {max_bytes: 46},
                         source: "<div><p>some text 1</p><p>some text 2</p></div>",
                         expected: "<div><p>some text 1</p><p>some te...</p></div>"

      it_should_truncate_bytes "html text with nested tags (empty contents)", with: {max_bytes: 14},
                         source: "<div><p>some text 1</p><p>some text 2</p></div>",
                         expected: "<div>...</div>"

      it_should_truncate_bytes "html text with special html entities", with: {max_bytes: 15},
                         source: "<p>&gt;some text</p>",
                         expected: "<p>&gt;s...</p>"

      it_should_truncate_bytes "html text with siblings tags", with: {max_bytes: 64},
                         source: "<div>some text 0</div><div><p>some text 1</p><p>some text 2</p></div>",
                         expected: "<div>some text 0</div><div><p>some text 1</p><p>som...</p></div>"

      it_should_truncate_bytes "html with unclosed tags", with: {max_bytes: 151},
                         source: "<table><tr><td>Hi <br> there</td></tr></table>",
                         expected: "<table><tr><td>Hi <br/> there</td></tr></table>"

      it_should_truncate_bytes "sdasd", with: {max_bytes: 100},
                         source: "<span>Foo&nbsp;Bar</span>", expected: "<span>Foo#{NBSP}Bar</span>"
    end

    describe "insert tail between two or more final tags" do
      it_should_truncate_bytes "html text as normal when tail_before_final_tag option is not set",
                          with: {max_bytes: 27},
                          source: "<p><span>some text</span>some more text</p>",
                          expected: "<p><span>some...</span></p>"

      it_should_truncate_bytes "html text when tail_before_final_tag: true by inserting tail before the final tag, and after any other closing tags",
                          with: {max_bytes: 27, tail_before_final_tag: true},
                          source: "<p><span>some text</span>some more text</p>",
                          expected: "<p><span>some</span>...</p>"
    end

    describe "single html tag elements" do
      it_should_truncate_bytes "html text with <br /> element without adding a closing tag", with: {max_bytes: 30},
                         source: "<div><h1><br/>some text 1</h1><p>some text 2</p></div>",
                         expected: "<div><h1><br/>so...</h1></div>"

      it_should_truncate_bytes "html text with <img/> element without adding a closing tag", with: {max_bytes: 45},
                         source: "<div><p><img src='some_path'/>some text 1</p><p>some text 2</p></div>",
                         expected: "<div><p><img src='some_path'/>so...</p></div>"
    end

    describe "comment html element" do
      it_should_truncate_bytes "html text and ignore <!-- a comment --> element by default", with: {max_bytes: 18},
                         source: "<!-- a comment --><p>some text 1</p>",
                         expected: "<p>some text 1</p>"

      it_should_truncate_bytes "html text with <!-- a comment --> element", with: {max_bytes: 35, comments: true},
                         source: "<!-- a comment --><p>some text 1</p>",
                         expected: "<!-- a comment --><p>some te...</p>"

      it_should_truncate_bytes "html text with <!-- a comment --> element that exceeds the max_bytes", with: {max_bytes: 12, comments: true},
                         source: "<!-- a comment --><p>some text 1</p>",
                         expected: "<!-- a...-->"

      it_should_truncate_bytes "html text with <!-- a comment --> element with other elements that exceeds max_bytes", with: {max_bytes: 28, comments: true},
                         source: "<!-- a comment --><p>some text 1</p>",
                         expected: "<!-- a comment --><p>...</p>"
    end

    describe "html attributes" do
      it_should_truncate_bytes "html text with 1 attributes", with: {max_bytes: 23},
                         source: "<p attr1='1'>some text</p>",
                         expected: "<p attr1='1'>som...</p>"

      it_should_truncate_bytes "html text with 2 attributes", with: {max_bytes: 33},
                         source: "<p attr1='1' attr2='2'>some text</p>",
                         expected: "<p attr1='1' attr2='2'>som...</p>"

      it_should_truncate_bytes "html text with attributes in nested tags", with: {max_bytes: 35},
                         source: "<div><p attr1='1'>some text</p></div>",
                         expected: "<div><p attr1='1'>some...</p></div>"

      it_should_truncate_bytes "html text with attribute containing entities respecting them", with: {max_bytes: 28, filtered_attributes: ['attr2']},
                         source: "<p attr1='&gt;some'>some text</p>",
                         expected: "<p attr1='&gt;some'>s...</p>"

      it_should_truncate_bytes "html text with 2 attributes filtering one of them", with: {max_bytes: 90, filtered_attributes: ['attr2']},
                         source: "<p attr1='1'>some text</p><p attr2='2'>filtered text</p>",
                         expected: "<p attr1='1'>some text</p><p>filtered text</p>"


      it_should_truncate_bytes "html text with 2 attributes filtering all of them", with: {max_bytes: 13, filtered_attributes: ['attr1', 'attr2']},
                         source: "<p attr1='1' attr2='2'>some text</p>",
                         expected: "<p>som...</p>"
    end

    describe "excluded tags" do
      it_should_truncate_bytes "html text with a filtered tag", with: {max_bytes: 90, filtered_tags: %w(img)},
                         source: "<p><img/>some text</p>",
                         expected: "<p>some text</p>"

      it_should_truncate_bytes "html text with a filtered tag with nested tags", with: {max_bytes: 90, filtered_tags: %w(table img)},
                         source: "<div><table><tr>Hi there</tr></table>some text<img/></div>",
                         expected: "<div>some text</div>"

      it_should_truncate_bytes "html text with a filtered tag with nested tags where nested tags are filtered", with: {max_bytes: 90, filtered_tags: %w(table tr img)},
                         source: "<div><table><tr><td>Hi there</td></tr></table>some text<img/></div>",
                         expected: "<div>some text</div>"
    end
  end
end
