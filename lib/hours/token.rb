module Hours
  class Token
    attr_accessor :word, :tag, :value

    def initialize(word)
      @word = word
    end

    def tagged?
      !tag.nil?
    end
  end
end
