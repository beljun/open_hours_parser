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

      # Replace newlines
      t = t.gsub "\n", ' '

      # Chinese 
      t = t.gsub '星期一', ' monday -'
      t = t.gsub '至五', ' friday '

      t = t.gsub '至六', ' saturday '
      t = t.gsub '星期六、日及公眾假期', ' saturday - sunday ' 
      t = t.gsub '至日', ' sunday '
      t = t.gsub '星期日', ' sunday '
      t = t.gsub '日及公眾假期', ' sunday '
      t = t.gsub '星期日及公眾假期', ' sunday '

      # Common expressions
      t = t.gsub 'weekday', ' monday - friday '

      # strange unicode
      t = t.gsub '：', ': '
      t = t.gsub '；', '; '
      t = t.gsub '–', '-'
      t = t.gsub '一', '-'

      t = t.gsub /([-;,.&])/, ' \1 '
      t = t.gsub '(', ' ( '
      t = t.gsub ')', ' ) '
    end
  end
end
