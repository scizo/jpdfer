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
        :must_not_be_left_blank_field => ''
      }
    end
  end

  describe '#get_field' do
    it 'should return the field value' do
      @pdf.get_field(:important_field).should == ""
    end
  end

  describe '#set_field' do
    it 'should fill the field with given name with given value' do
      @pdf.set_field(:important_field, "I am important")
      @pdf.get_field(:important_field).should == "I am important"
    end

    it 'should update fields' do
      @pdf.set_field(:important_field, "I am important")
      @pdf.fields.should == {
        :important_field => 'I am important',
        :unimportant_field => '',
        :semiimportant_field => '',
        :tuesday_field => '',
        :must_not_be_left_blank_field => ''
      }
    end
  end

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

      new_pdf = Pdf.new(@new_path)
      new_pdf.fields.should == {
        :important_field => '',
        :unimportant_field => '',
        :semiimportant_field => '',
        :tuesday_field => '',
        :must_not_be_left_blank_field => ''
      }
    end

    it 'should save updated fields to the new file' do
      @pdf.set_field(:important_field, "I am important")
      @pdf.save_as(@new_path)

      new_pdf = Pdf.new(@new_path)
      new_pdf.get_field(:important_field).should == "I am important"
    end
  end
end
