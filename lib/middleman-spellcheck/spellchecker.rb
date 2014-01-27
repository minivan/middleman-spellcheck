class Spellchecker
  require 'net/https'
  require 'uri'
  require 'rexml/document'

  ASPELL_WORD_DATA_REGEX = Regexp.new(/\&\s\w+\s\d+\s\d+(.*)$/)

  @@aspell_path = "aspell"

  def self.aspell_path=(path)
    @@aspell_path = path
  end

  def self.aspell_path
    @@aspell_path
  end

  def self.check(text, lang='en')
    tmp = Tempfile.new('spellchecker-tmp')
    tmp << text
    tmp.flush
    tmp.close
    spell_check_response = `cat "#{tmp.path}" | #{@@aspell_path} -a -l #{lang}`
    if spell_check_response == ''
      raise 'Aspell command not found'
    elsif text == ''
      return []
    else
      response = text.split(' ').collect { |original| {:original => original} }
      results = spell_check_response.split("\n").slice(1..-1)
      result_index = 0
      response.each_with_index do |word_hash, index|
        if word_hash[:original] =~ /[a-zA-z\[\]\?]/
          if results[result_index] =~ ASPELL_WORD_DATA_REGEX
            response[index].merge!(:correct => false, :suggestions => results[result_index].split(':')[1].strip.split(',').map(&:strip))
          else
            response[index].merge!(:correct => true)
          end
          result_index += 1
        else
          response[index].merge!(:correct => true)
        end
      end
      return response
    end
  end
end
