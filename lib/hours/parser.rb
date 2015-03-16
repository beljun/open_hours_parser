module Hours
  class Parser
    def parse(text)
      tokenize(text)
    end

    private

    def tokenize(text)
      t = pre_normalize(text)
      tokens = t.split(' ').map { |word| Token.new(word) }
      tokens = Tagger.new.scan(tokens)
      tokens.select { |token| token.tagged? }
    end

    def pre_normalize(text)
      t = text.dup.to_s.downcase
      t = t.gsub(/-/, ' - ')
      t = t.gsub(/,/, ' , ')
    end
  end
end
