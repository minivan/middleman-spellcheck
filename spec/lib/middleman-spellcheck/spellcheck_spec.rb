require 'rspec'
require_relative '../../../lib/middleman-spellcheck/spellchecker'

describe Spellchecker do
  let(:text)   { "hello, world! of txet" }
  let(:result) { Spellchecker.check(text) }

  it "can spell check words" do
    result.should == { "hello" => :correct,
                       "world" => :correct,
                       "of"    => :correct,
                       "txet"  => :incorrect }
  end
end
