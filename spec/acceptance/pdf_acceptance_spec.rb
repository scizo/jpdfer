require 'spec_helper'

describe "Pdf Acceptance" do
  before(:each) do
    @pdf_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'simple_form.pdf'))
    @pdf = Pdf.new(@pdf_path)
    @values = {}
  end

  describe 'sanity check' do
    it 'should be sane' do
      69.should == 69
    end
  end

  describe '.new' do
    it 'should create new pdf' do
      @pdf.should_not be_nil
    end

    describe 'given missing file' do
      it 'should raise Errno::ENOENT (File Not Found)' do
        lambda { Pdf.new('derp.pdf') }.should raise_error(Errno::ENOENT)
      end
    end
  end

  describe '#fields' do
    it 'should return a hash of field name value pairs' do
      @pdf.fields.should == {
        :important_field => '',
        :unimportant_field => '',
        :semiimportant_field => '',
        :tuesday_field => '',
        :must_not_be_left_field => ''
      }
    end
  end

  # describe '#set_field' do
  #   it 'should fill the field with given name with given value' do
  #     pdf = Pdf.new(@pdf_path)
  #     pdf.set_field(:
  #   end
  # end

  describe '#save_as' do
    before(:each) do
      @new_path = File.join(File.dirname(@pdf_path), 'simple_form_new.pdf')
      FileUtils.rm_f(@new_path)
    end

    after(:each) do
      FileUtils.rm_f(@new_path)
    end

    it 'should write the pdf to a new path' do
      @pdf.save_as(@new_path)

      checksum(@pdf_path).should == checksum(@new_path)
    end
  end
end
