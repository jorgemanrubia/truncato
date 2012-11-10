require "spec_helper"

describe "Truncato" do
  describe "normal strings" do
    it_should_truncate "no html text with longer length", with: {max_length: 13, tail: '...'}, source: "some text", expected: "some text"
    it_should_truncate "no html text with shorter length", with: {max_length: 3}, source: "some text", expected: "som..."
    it_should_truncate "no html text with longer length", with: {max_length: 4}, source: "some", expected: "some"
  end

  describe "html strings" do
    it_should_truncate "simple html text with shorter string", with: {max_length: 3}, source: "<p>some text</p>", expected: "<p>s...</p>"
  end

end

