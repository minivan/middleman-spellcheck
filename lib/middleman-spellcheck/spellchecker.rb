class Spellchecker
  @@aspell_path = "aspell"
  @@aspell_cmdargs = ""
  @@debug_enabled = 0

  def self.aspell_path=(path)
    @@aspell_path = path
  end

  def self.aspell_path
    @@aspell_path
  end

  def self.cmdargs=(args)
    @@aspell_cmdargs = args
  end

  def self.cmdargs
    @@aspell_cmdargs
  end

  def self.debug_enabled=(args)
    @@debug_enabled = args
  end

  def self.debug_enabled
    @@debug_enabled
  end

  def self.sdbg(*args)
    if @@debug_enabled <= 0
      return
    end
    print "# DBG ", *args, "\n"
  end

  def self.query(words, lang)
    args = "-a -l #{lang}"
    if @@aspell_cmdargs != ""
      args = @@aspell_cmdargs
    end
    cmd = %Q<#{@@aspell_path} #{args}>
    result = []

    sdbg "Starting aspell"
    IO.popen(cmd, "a+", :err=>[:child, :out]) { |f|
      val = f.gets.strip()	# skip the Aspell's intro
      sdbg "Expected Aspell intro, got #{val}"
      words.each do |word|
        sdbg "-> Writing word '#{word}'"
        f.write(word + "\n")
        f.flush

        # should be * or &
        word_check_res = f.gets.strip()
        sdbg "<- got result '#{word_check_res}'"

        # skip the empty line
        val = f.gets()
	sdbg "Expected empty line, got '#{val}'"

        result << word_check_res
      end
    }
    raise 'Aspell command not found' unless result
    result || []
  end

  def self.correct?(result_string)
    result_string == "*"
  end

  def self.check(text, lang)
    # do ’ -> ' for aspell. Otherwise 's' is passed as a word to aspell.
    text.gsub! '’', '\''
    sdbg "self.check got raw text:\n#{text}\n"

    words = text.split(/[^A-Za-z']+/).select { |s|
       s != "" and s != "'s" and s != "'"
    }
    sdbg "self.check word array:\n#{words}\n"

    results = query(words, lang).map do |query_result|
      correct?(query_result)
    end

    words.zip(results).map {|word, correctness| { word: word, correct: correctness } }
  end
end
