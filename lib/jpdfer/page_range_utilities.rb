module Jpdfer
  module PageRangeUtilities
    module_function

    def normalize_page_range page_range
      pages = expand_page_range page_range
      split_list pages
    end

    def expand_page_range page_range
      page_range.split(',').reduce([]) do |result, sub_range|
        if sub_range.include? '-'
          raise "Invalid Range: #{sub_range}" unless sub_range =~ /^\d+-\d+$/
          first, last = sub_range.split '-'
          result.concat (first.to_i..last.to_i).to_a
        else
          raise "Invalid Range: #{sub_range}" unless sub_range.to_i.to_s == sub_range
          result << sub_range.to_i
        end
      end
    end

    def split_list list
      list.reduce([[]]) do |result, number|
        current = result.last
        if current.include? number
          result << [number]
        else
          current << number
          result
        end
      end
    end
  end
end
