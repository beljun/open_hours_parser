module Hours
  class Chunker
    attr_reader :tokens, :notated

    def initialize(tokens)
      @tokens = tokens
      @notated = @tokens.collect.with_index { |el, i| "#{el.tag.to_s}_#{i}" }.join(' ')
    end

    def extract
      open_hours = OpenHours.new
      open_hours.entries = match_days_times notated
      open_hours
    end

    private

    def token_value str
      tokens[str.match(/_(\d+)/)[1].to_i].value
    end

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

