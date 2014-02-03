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

  def self.transform_result(result_string)
    result_string == "*" ? :correct : :incorrect
  end

  def self.check(text, lang='en')
    words   = text.split(/\W+/)
    results = query(text, lang).map do |query_result|
      transform_result(query_result)
    end

    Hash[*words.zip(results).flatten]
  end
end
