require 'rspec'
require_relative '../../../lib/middleman-spellcheck/spellchecker'

describe Spellchecker do
  let(:text)   { "hello, world! of txet" }
  let(:result) { Spellchecker.check(text) }

  it "can spell check words" do
    result.should == [{ word: "hello", correct: true },
                      { word: "world", correct: true },
                      { word: "of", correct: true },
                      { word: "txet", correct: false }]
  end
end
