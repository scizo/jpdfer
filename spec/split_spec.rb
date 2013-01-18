require 'spec_helper'

module Jpdfer
  describe Split do
    describe '.string_to_interval' do
      it 'should convert the string \'1\' to [1, 1]' do
        Jpdfer::Split.string_to_interval('1').should == [1, 1]
      end

      it 'should convert the string \'1-5\' to [1, 5]' do
        Jpdfer::Split.string_to_interval('1-5').should == [1, 5]
      end
    end
    
    describe '.split_string' do
      it "should convert '' to ['']" do
        Jpdfer::Split.split_string('').should == ['']
      end
      
      it "should convert '1' to '1'" do
        Jpdfer::Split.split_string('1').should == ['1']
      end
      
      it "should convert '1-2' to '1-2'" do
        
        Jpdfer::Split.split_string('1-2').should == ['1-2']
      end
    
      it "should convert '1-2,3-4,5-6,7' to ['1-7']" do
        Jpdfer::Split.split_string('1-2,3-4,5-6,7').should == ['1-7']
      end

      it "should convert '1-2,3,4,6' to ['1-4,6']" do
        Jpdfer::Split.split_string('1-2,3,4,6').should == ['1-4,6']
      end

      it "should convert '1-2,3,2,4-5,6' to ['1-3','2,4-6']" do
        Jpdfer::Split.split_string('1-2,3,2,4-5,6').should == ['1-3','2,4-6']
      end

      it "should convert '1-2,3,2,4-5,6' to ['1-3','2,4-6']" do
        Jpdfer::Split.split_string('1-2,3,2,4-5,6').should == ['1-3','2,4-6']
      end

      it "should convert '1,1,1,2,3,4,5,2,3,5,6' to ['1', '1', '1-5', '2-3,5-6']" do
        Jpdfer::Split.split_string('1,1,1,2,3,4,5,2,3,5,6').should == ['1', '1', '1-5', '2-3,5-6']
      end
    end
  end
end

