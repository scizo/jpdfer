require 'spec_helper'


# IMPORTANT: These are model/unit specs! Test in isolation as much as possible!
describe Pdf do
  before(:each) do
    @data_path = File.join(JPDFER_ROOT, 'spec', 'data')
    @pdf_path = File.join(@data_path, 'simple_form.pdf')
    @pdf = Pdf.new(@pdf_path)
    @values = {}
  end

  describe 'sanity check' do
    it 'should be sane' do
      42.should == 42
    end
  end
  
  describe '.new' do
    it 'should create new pdf' do
      @pdf.should_not be_nil
    end
  end

  describe '#fields' do
    # Hold this off until PdfReader's API settles down
    # it 'should delegate to PdfReader' do
    #   @pdf_reader = mock(PdfReader)
    #   PdfReader.stub!(:new).and_return(@pdf_reader)
    #   @pdf_reader.should_receive(:fields).and_return({:test => 'yes' })
      
    #   # stub pdf's internal PdfReader accessor... somehow...?
    #   @pdf.fields.should == {:test => 'yes' }
    # end
  end
end

#   describe '#set_field' do
#     it 'should fill the field with given name with given value' do
#       pdf = Pdf.new(@pdf_path)
#       pdf.set_field(:
#     end
#   end

#   describe '#save_as' do
#     before(:each) do
#       @new_path = File.join(File.dirname(@pdf_path), 'simple_form_new.pdf')
#       FileUtils.rm_f(@new_path)
#     end

#     after(:each) do
#       FileUtils.rm_f(@new_path)
#     end

#     it 'should write the pdf to a new path' do
#       @pdf.save_as(@new_path)

#       checksum(@pdf_path).should == checksum(@new_path)
