require 'rspec'
require_relative '../../../lib/middleman-spellcheck/spellchecker'

describe Spellchecker do
  let(:text)   { "hello, world! of txet" }
  let(:result) { Spellchecker.check(text) }

  context "with one wrong word" do
    it "can spell check words" do
      result.should == [{ word: "hello", correct: true },
                        { word: "world", correct: true },
                        { word: "of", correct: true },
                        { word: "txet", correct: false }]
    end
  end

  context "ignoring special characters" do
    let(:text) { "Hello, dear!\nMy name is Lucy."}

    it "spells correctly with newline characters" do
      result.should == [{ word: "Hello", correct: true },
                        { word: "dear", correct: true},
                        { word: "My", correct: true},
                        { word: "name", correct: true},
                        { word: "is", correct: true},
                        { word: "Lucy", correct: true}]
    end
  end
end
