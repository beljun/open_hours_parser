module Hours
  # This is a very naive, hand-coded shallow parser. In real life, we'd get more mileage if we start from an existing library.
  class Chunker
    attr_reader :tokens, :notated

    def initialize(tokens)
      @tokens = tokens

      # A custom notation to represent the tokens and tags into a single string.
      # We'll use this notated string to detect chunks via regular expressions on tokens.
      # Regular expressions because didn't wanna write a left-to-right parser from scratch.
      @notated = @tokens.collect.with_index { |el, i| "#{el.tag.to_s}_#{i}" }.join(' ')
    end

    def extract
      open_hours = OpenHours.new

      # Decide which handler to invoke depending on phrase (DAYS and TIMES vs TIMES and DAYS).
      first_relevant_tag = tokens.find { |el| [:DAY, :TIME].include? el.tag }.tag

      open_hours.entries = 
        if first_relevant_tag == :TIME
          match_times_days notated
        else
          match_days_times notated
        end

      open_hours
    end

    private

    def token_value str
      tokens[str.match(/_(\d+)/)[1].to_i].value
    end

    # Phrase is DAYS and then TIME with possible repetitions.
    def match_days_times str
      entries = []
      matches = str.scan /((?:(?:DAY|TO)_\d+\s*)+)((?:(?:TIME|TO)_\d+\s*)+)/
      matches.each do |match|
        entry = {}
        entry[:days] = match_days match[0]
        entry[:hours] = match_hours match[1]
        entries << entry
      end

      entries
    end

    # Phrase is TIMES and then DAYS with possible repetitions.
    def match_times_days str
      entries = []
      matches = str.scan /((?:(?:TIME|TO)_\d+\s*)+)((?:(?:DAY|TO)_\d+\s*)+)/
      matches.each do |match|
        entry = {}
        entry[:days] = match_days match[1]
        entry[:hours] = match_hours match[0]
        entries << entry
      end

      entries
    end

    def match_days str
      days = []
      # day ranges
      matches = str.scan /((DAY_\d+) (?:TO_\d+\s*)+ (DAY_\d+))+/
      matches.each do |match|
        days << Range.new(token_value(match[1]).to_i, token_value(match[2]).to_i)
      end

      # individual days
      matches = str.gsub(/((DAY_\d+) (?:TO_\d+\s*)+ (DAY_\d+))+/, '').scan /DAY_\d+/
      matches.each do |match|
        days << token_value(match).to_i
      end

      days
    end

    def match_hours str
      hours = []
      matches = str.scan /((TIME_\d+) (?:TO_\d+\s*)+ (TIME_\d+))+/
      matches.each do |match|
        a = token_value(match[1]).to_i
        b = token_value(match[2]).to_i 

        hours << Range.new(a, (b < a ? b + 1440 : b))
      end
      hours
    end
  end
end

