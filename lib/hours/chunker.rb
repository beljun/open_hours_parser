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
      tokens[str.match(/_(\d+)/)[1].to_i].value if str
    end

    # Phrase is DAYS and then TIME with possible repetitions.
    def match_days_times str
      entries = []
      matches = str.scan /((?:(?:DAY|TO)_\d+\s*)+)((?:(?:TIME|TO|AMPM)_\d+\s*)+)/
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
      matches = str.scan /((?:(?:TIME|TO|AMPM)_\d+\s*)+)((?:(?:DAY|TO)_\d+\s*)+)/
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
      matches = str.scan /((TIME_\d+)(\s*AMPM_\d+)? (?:TO_\d+\s*)+ (TIME_\d+)(\s*AMPM_\d)?)+/
      hours = matches.collect do |match|
        t1, ampm1, t2, ampm2 = token_value(match[1]).to_i, token_value(match[2]), token_value(match[3]).to_i, token_value(match[4])
        a = t1 < 12*60 && (ampm1 || ampm2) == :pm ? t1 + 12*60 : t1
        b = t2 < 12*60 && ampm2 == :pm ? t2 + 12*60 : t2
        Range.new(a, (b < a ? b + 24*60 : b))
      end
      hours
    end
  end
end

