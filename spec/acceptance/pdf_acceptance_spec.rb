require 'spec_helper'

describe "Pdf Acceptance" do
  before(:each) do
    @pdf_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'simple_form.pdf'))
    @pdf = Pdf.new(@pdf_path)
    @values = {}
    @unfilled_fields = {
      :important_field => '',
      :unimportant_field => '',
      :semiimportant_field => '',
      :tuesday_field => '',
      :must_not_be_left_blank_field => ''
    }
    @filled_fields = {
      :important_field => "I am important",
      :unimportant_field => 'I am unimportant',
      :semiimportant_field => 'I am confused',
      :tuesday_field => 'Is it Tuesday already?',
      :must_not_be_left_blank_field => 'NOT BLANK'
    }
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
      @pdf.fields.should == @unfilled_fields
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

    it 'should update field' do
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

  describe '#set_fields' do
    it 'should fill the fields with given names with given values' do
      @pdf.set_fields(@filled_fields)
      @pdf.get_field(:important_field).should == "I am important"
      @pdf.get_field(:unimportant_field).should == 'I am unimportant'
      @pdf.get_field(:semiimportant_field).should == 'I am confused'
      @pdf.get_field(:tuesday_field).should == 'Is it Tuesday already?'
      @pdf.get_field(:must_not_be_left_blank_field).should == 'NOT BLANK'
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

#     describe "with nonexistent field name" do
#       it "should raise Pdf::NonexistentFieldError" do
#         lambda { @pdf.set_field(:monkey, 'Spider') }.should raise_error(Pdf::NonexistentFieldError)
#       end
#     end
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


  # save_as returns *UNTESTED* if the PDF form is not valid
  # save_as returns *UNTESTED* if the file cannot be written
  # fields returns *UNTESTED* if PDF document does not contain a form
  # get_field returns *UNTESTED* if field does not exist
  # get_field returns *UNTESTED* if PDF document does not contain a form
  # set_field returns value? true? *UNTESTED*.
  # set_field returns *UNTESTED* if field is not found
  # set_field returns *UNTESTED* if PDF document does not contain a form
  # set_fields returns (what data type? hash? true?) *UNTESTED*.
  # set_fields returns *UNTESTED* if field is not found
  # set_fields returns *UNTESTED* if PDF document does not contain a form

end
