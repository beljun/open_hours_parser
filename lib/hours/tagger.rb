module Hours
  class Tagger
    def scan(tokens)
      tokens.map.with_index do |token, i|
        word = token.word
        token.tag(:sunday) if word =~ /^su[nm](day)?/
        token.tag(:monday) if word =~ /^m[ou]n(day)?/
        token.tag(:tuesday) if word =~ /^t(ue|eu|oo|u)s?(day)?/
        token.tag(:wednesday) if word =~ /^we(d|dnes|nds|nns)(day)?/
        token.tag(:thursday) if word =~ /^th(u|ur|urs|ers)(day)?/
        token.tag(:friday) if word =~ /^fr[iy](day)?/ 
        token.tag(:saturday) if word =~ /^sat(t?[ue]rday)?/
        token.tag(:day_name) if token.has_tag? [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
        
        token.tag(:range_to) if word =~ /^(-|to|until)$/

        token.tag(:time) if word =~  /^\d{1,2}(:?\d{1,2})?$/

        token
      end.flatten
    end
  end
end
