module Jpdfer
  module Split
    module_function

    def split_string(interval_string)
      interval_list_list = build_interval_list_list(interval_string)
      
      reduced_interval_list_list = reduce_interval_list_list(interval_list_list)
      
      build_interval_string_list(reduced_interval_list_list)
    end

    def build_interval_list_list(interval_strings)
      interval_strings.split(',').map {|s| [string_to_interval(s)]}
    end
    
    def reduce_interval_list_list(interval_list_list)
      interval_list_list.reduce([[]]) do |result,element|
        new_last,remainder=merge_interval_list_lists(result.last,element)
        if remainder.empty?
          replace_last(result,new_last)
        else
          result.clone << element
        end
      end
    end

    def build_interval_string_list(interval_list_list)
      interval_list_list.map {|intervals| build_interval_string(intervals)}
    end
    
    def string_to_interval(s)
      if s.nil? || s.empty?
        return nil
      end
      
      interval=s.split('-').map{|s| verified_to_i(s)}
      return interval if interval.size == 2
      return interval << interval[0] if interval.size == 1
      return nil
    end
    
    def merge_interval_list_lists(list_a,list_b)
      if list_a.empty?
        return list_b,[]
      end
      
      if list_b.empty?
        return list_a,list_b
      end
      
      head_b = list_b[0]
      tail_b = list_b[1..-1]

      if can_merge?(list_a,head_b)
        return merge_interval_list_lists(merge_interval(list_a,head_b),tail_b)
      else
        return list_a,list_b
      end
    end

    def build_interval_string(intervals)
      intervals.map do |i|
        i0,i1=i
        i0 == i1 ? "#{i0}" : "#{i0}-#{i1}"
      end.join(',')
    end

    def verified_to_i(s)
      result = s.to_i
      if result.to_s == s
        result
      else
        raise StandardError.new('invalid integer: ' + s)
      end
    end
    
    def can_merge?(interval_list,interval)
      !interval_list.nil? &&
        !interval_list.any? {|list_interval| overlapping?(list_interval,interval)}
    end
    
    def merge_interval(interval_list,interval)
      if interval_list.nil? || interval_list.empty?
        return [interval]
      end

      if adjoining?(interval_list.last,interval)
        return replace_last(interval_list,join_intervals(interval_list.last,interval))
      end

      interval_list.clone << interval
    end

    def overlapping?(a,b)
      a0,a1=a
      b0,b1=b
      within?(a0,b0,b1) ||
        within?(a1,b0,b1) ||
        within?(b0,a0,a1) ||
        within?(b1,a0,a1)
    end

    def adjoining?(a,b)
      a0,a1=a
      b0,b1=b
      b0 == (a1 + 1)
    end

    def join_intervals(a,b)
      if !adjoining?(a,b)
        raise StandardError.new("can't join intervals #{a.inspect},#{b.inspect}")
      end
      [a[0],b[1]]
    end
    
    def replace_last(list,new_last)
      new_list=list.clone
      new_list[-1]=new_last
      new_list
    end

    def within?(a,b,c)
      a >= b && a <= c || a >= c && a <= b
    end
  end
end
