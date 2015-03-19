module Hours
  class Tagger
    # Detect if a token belongs to one of the relevant categories and tag (DAY, TO, TIMES).
    def scan(tokens)
      tokens.map.with_index do |token, i|
        word = token.word

        # Match day names.
        token.tag, token.value = :DAY, 0 if word =~ /^su[nm](day)?/
        token.tag, token.value = :DAY, 1 if word =~ /^m[ou]n(day)?/
        token.tag, token.value = :DAY, 2 if word =~ /^t(ue|eu|oo|u)s?(day)?/
        token.tag, token.value = :DAY, 3 if word =~ /^we(d|dnes|nds|nns)(day)?/
        token.tag, token.value = :DAY, 4 if word =~ /^th(u|ur|urs|ers)(day)?/
        token.tag, token.value = :DAY, 5 if word =~ /^fr[iy](day)?/ 
        token.tag, token.value = :DAY, 6 if word =~ /^sat(t?[ue]rday)?/
       
        # Match range symbols 
        token.tag = :TO if word =~ /^(-|to|until)$/

        # Match am/pm modifiers
        token.tag, token.value = :AMPM, word.to_sym if word =~ /^(am|pm)$/

        # Match times (00:00 to 28:00); val is time in minutes.
        match = word.scan /^(\d{1,2})(?::?(\d{2}))?$/
        if match && !match.empty?
          time_in_minutes = (match[0][0]).to_i * 60 + (match[0][1]).to_i
          token.tag, token.value = :TIME, token.value = time_in_minutes if time_in_minutes <= 28*60
        end

        token
      end.flatten
    end
  end
end
