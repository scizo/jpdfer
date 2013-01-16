module Jpdfer
  module Split
    module_function

    def split_string(interval_string)
      result = build_string(split_string_aux([],nil,interval_string.split(',')))
      puts "split_string('#{interval_string}'): '#{result}'"
      result
    end

    def split_string_aux(result,last,interval_strings)

      puts "#{result.inspect},#{last.inspect},#{interval_strings.inspect}"
      
      next_interval_string,new_interval_strings = next_interval(interval_strings)

      puts "next_interval_string: #{next_interval_string},new_interval_strings: #{new_interval_strings.inspect}"
      
      if next_interval_string.nil?
        if last.nil?
          return result
        else
          return result << last
        end
      end

      next_interval = string_to_interval(next_interval_string)

      if last.nil?
        return split_string_aux(result, next_interval,new_interval_strings)
      end

      if  (overlapping?(next_interval,last) ||
          result.any? {|interval| overlapping?(interval,next_interval)})
        
        return split_string_aux(result << last,next_interval,new_interval_strings)
      end
      
      if adjoining?(last,next_interval)
        return split_string_aux(result,join_intervals(last,next_interval),new_interval_strings)
      end
      
      return split_string_aux(result << last, next_interval,new_interval_strings)
    end

    def next_interval(interval_strings)
      first,rest = interval_strings[0],interval_strings[1..-1]
      [first,rest]
    end
    
    def build_string(intervals)
      intervals.map do |i|
        i0,i1=i
        i0 == i1 ? "#{i0}" : "#{i0}-#{i1}"
      end.join(',')
    end
    

    def adjoining?(a,b)
      a0,a1=a
      b0,b1=b
      puts "#{a1},#{b0}"
      b0 == (a1 + 1)
    end

    def join_intervals(a,b)
      if !adjoining?(a,b)
        raise StandardError.new("can't join intervals #{a.inspect},#{b.inspect}")
      end

      [a[0],b[1]]
    end
    
    def overlapping?(a,b)
      a0,a1=a
      b0,b1=b
      within?(a0,b0,b1) ||
      within?(a1,b0,b1) ||
      within?(b0,a0,a1) ||
      within?(b1,a0,a1)
    end

    def within?(a,b,c)
      a >= b && a <= c || a >= c && a <= b
    end
    
    def verified_to_i(s)
      result = s.to_i
      if result.to_s == s
        result
      else
        raise StandardError.new('invalid integer: ' + s)
      end
    end
    
    def string_to_interval(s)
      interval=s.split('-').map{|s| verified_to_i(s)}
      return interval if interval.size == 2
      return interval << interval[0] if interval.size == 1
      return nil
    end
        
  end
end
