module Hours
  # The parsed opening hours from the chunker go here. 
  # They are then normalized (continuous ranges are merged, etc).
  # to_s() transforms into the expected output syntax (see tests).
  class OpenHours
    attr_accessor :entries

    def initialialize
      @entries = []
      @week_hours, @merged_hours = nil, nil
    end

    # Transforms the normalized hours into the expected output syntax as required by the specs.
    def to_s
      opens = 
        merged_hours.sort_by { |el| [display_sort_priority(el[:days].first), el[:days].first.to_s] }.collect do |el|
          hours = 
            el[:hours].collect do |hr|
              "#{time_to_s(hr.begin)}-#{time_to_s(hr.end)}"
            end.join(',')

          days = 
            el[:days].collect do |day|
              day.is_a?(Range) ? [day.begin, day.end].join('-') : day.to_s
            end.join(',')
          
          [days, hours].join(':') 
        end
      "S#{opens.join(';')}"
    end

    # Table of hours is transformed into arrays or ranges of continuous days.
    # Crossover from Sunday to Monday are also handled. 
    def merged_hours
      return @merged_hours if @merged_hours

      similar_spans = week_hours.values.collect { |el| el.hash }.uniq
      @merged_hours = 
        similar_spans.collect do |span|
          similar_days = week_hours.select { |k,v| v.hash == span }.keys
          {:days => cyclic_ranges(array_to_ranges(similar_days)), :hours => week_hours[similar_days.first]}
        end
    end

    # Normalized table of hours for the week (7 days).
    # Also, overlapping hour ranges within a day are merged.
    def week_hours
      return @week_hours if @week_hours

      wh = {}
      entries.each do |entry|
        days = 
          entry[:days].collect do |day|
            if day.is_a? Range
              if day.begin > day.end
                ((day.begin)..(day.end + 7)).collect { |el| el%7 }
              else
                day.to_a
              end
            else
              day
            end
          end.flatten.sort.uniq

        days.each do |day|
          wh[day] ||= []
          wh[day] << entry[:hours]
        end
      end

      @week_hours = {}
      wh.each do |k,v|
        @week_hours[k] = merge_overlapping_ranges(v.flatten)
      end
      @week_hours
    end

    private

    def ranges_overlap? a, b
      a.include?(b.begin) || b.include?(a.begin)
    end

    def merge_ranges a, b
      [a.begin, b.begin].min..[a.end, b.end].max
    end

    def merge_overlapping_ranges(ranges)
      ranges.sort_by(&:begin).inject([]) do |ranges, range|
        if !ranges.empty? && ranges_overlap?(ranges.last, range)
          ranges[0...-1] + [merge_ranges(ranges.last, range)]
        else
          ranges + [range]
        end
      end
    end

    def array_to_ranges a
      a.sort.each_with_index.chunk { |x, i| x - i }.map do |diff, pairs|
        pairs.first[0] == pairs.last[0] ? pairs.first[0] : pairs.first[0] .. pairs.last[0]
      end
    end

    def cyclic_ranges a
      if a.size > 1 && (a.first.is_a?(Range) ? a.first.begin : a.first) == 0 && (a.last.is_a?(Range) ? a.last.end : a.last) == 6
        [(a.last.is_a?(Range) ? a.last.begin : a.last)..(a.first.is_a?(Range) ? a.first.last : a.first), a[1...-1]].flatten
      else
        a
      end
    end

    def display_sort_priority a
      case
        when a == 0
          0
        when a.is_a?(Range) && a.include?(0)
          0
        when a.is_a?(Range) && a.begin > a.end
          1
        else
          2
      end
    end

    def time_to_s a
      "#{'%02d' % (a/60)}#{'%02d' % (a%60)}"
    end
  end
end
