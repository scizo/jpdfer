require 'spec_helper'

module Jpdfer
  describe PageRangeUtilities do
    describe '.normalize_page_range' do
      it "should convert '' to []" do
        Jpdfer::PageRangeUtilities.normalize_page_range('').should == [[]]
      end

      it "should convert '1' to [1]" do
        Jpdfer::PageRangeUtilities.normalize_page_range('1').should == [[1]]
      end

      it "should convert '1-2' to [1,2]" do
        Jpdfer::PageRangeUtilities.normalize_page_range('1-2').should == [[1,2]]
      end

      it "should convert '1-2,3-4,5-6,7' to [1,2,3,4,5,6,7]" do
        Jpdfer::PageRangeUtilities.normalize_page_range('1-2,3-4,5-6,7').should == [[1,2,3,4,5,6,7]]
      end

      it "should convert '1-2,3,4,6' to [1,2,3,4,6]" do
        Jpdfer::PageRangeUtilities.normalize_page_range('1-2,3,4,6').should == [[1,2,3,4,6]]
      end

      it "should convert '1-2,3,2,4-5,6' to [[1,2,3],[2,4,6]]" do
        Jpdfer::PageRangeUtilities.normalize_page_range('1-2,3,2,4-5,6').should == [[1,2,3],[2,4,5,6]]
      end

      it "should convert '1-2,3,2,4-5,6' to [[1,2,3],[2,4,5,6]]" do
        Jpdfer::PageRangeUtilities.normalize_page_range('1-2,3,2,4-5,6').should == [[1,2,3],[2,4,5,6]]
      end

      it "should convert '1,1,1,2,3,4,5,2,3,5,6' to [[1],[1],[1,2,3,4,5],[2,3,5,6]]" do
        Jpdfer::PageRangeUtilities.normalize_page_range('1,1,1,2,3,4,5,2,3,5,6').should == [[1],[1],[1,2,3,4,5],[2,3,5,6]]
      end
    end
  end
end

