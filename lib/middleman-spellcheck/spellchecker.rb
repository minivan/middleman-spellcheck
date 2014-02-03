class Spellchecker
  @@aspell_path = "aspell"

  def self.aspell_path=(path)
    @@aspell_path = path
  end

  def self.aspell_path
    @@aspell_path
  end

  def self.query(text, lang='en')
    result = `echo "#{text}" | #{@@aspell_path} -a -l #{lang}`
    raise 'Aspell command not found' unless result
    result.split("\n")[1..-1]
  end

  def self.correct?(result_string)
    result_string == "*"
  end

  def self.check(text, lang='en')
    words   = text.split(/\W+/)
    results = query(text, lang).map do |query_result|
      correct?(query_result)
    end

    words.zip(results).map {|word, correctness| { word: word, correct: correctness } }
  end
end
