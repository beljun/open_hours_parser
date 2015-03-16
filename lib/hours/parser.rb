# encoding: UTF-8

module Hours
  class Parser
    def parse(text)
      tokens = tokenize(text)
      open_hours = Chunker.new(tokens).extract
      open_hours.to_s
    end

    def tokenize(text)
      t = pre_normalize(text)
      tokens = t.split(' ').map { |word| Token.new(word) }
      tokens = Tagger.new.scan(tokens)
      tokens.select { |token| token.tagged? }
    end

    private

    def pre_normalize(text)
      t = text.dup.to_s.downcase

      # strange unicode
      t = t.gsub '：', ': '
      t = t.gsub '；', '; '
      t = t.gsub '–', '-'
      
      t = t.gsub /([-;,.&])/, ' \1 ' 
    end
  end
end
