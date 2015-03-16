module Hours
  class Token
    attr_reader :word, :tags

    def initialize(word)
      @word = word
      @tags = []
    end

    def tag(new_tag)
      @tags << new_tag if new_tag
    end

    def tagged?
      tags.size > 0
    end

    def has_tag?(ask_tag)
      ask_tag = [ask_tag] unless ask_tag.is_a? Array
      (tags & ask_tag).size > 0
    end
  end
end
