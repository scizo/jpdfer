require 'spec_helper'

module Jpdfer

describe Pdf do
  before(:each) do
    @data_path = File.join(ROOT, 'spec', 'data')
    @pdf_path = File.join(@data_path, 'simple_form.pdf')
    @pdf = Pdf.new(@pdf_path)
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

  describe '.new' do
    it 'should create new pdf' do
      @pdf.should_not be_nil
    end

    describe 'given missing file' do
      it 'should raise Errno::ENOENT (File Not Found)' do
        lambda { Pdf.new('derp.pdf') }.should raise_error(Errno::ENOENT)
      end
    end

    describe 'given an optional keystore' do
      describe 'when Pdf is configured' do
        before(:each) do
          @keystore = KeyStore.new(
            File.join(@data_path, 'keystore.ks'),
            'jpdfer',
            'durrderp'
          )
          @pdf = Pdf.new(@pdf_path, :keystore => @keystore)
          @signed_pdf_path = File.join(@data_path, 'new_signed.pdf')
        end

        after(:each) do
          FileUtils.rm_f(@signed_pdf_path)
        end

        it 'should create a signed pdf if saved' do
          @pdf.save_as(@signed_pdf_path)
          File.open(@signed_pdf_path) do |file|
            data = file.read
            data['Scott Nielsen'].should == 'Scott Nielsen'
            data['Saxton Horne'].should == 'Saxton Horne'
          end
        end

        describe '#set_certification_level' do
          it 'should have the given certification level when saved' do
            @pdf.set_certification_level(:no_changes_allowed)
            @pdf.save_as(@signed_pdf_path)
            @pdf = Pdf.new(@signed_pdf_path)
            @pdf.certification_level.should == :no_changes_allowed
          end
        end

        # TODO: I would like to add this functionality but havn't researched the java
        # KeyStore and encryption classes enough yet
        #
        # describe 'given a pdf signed with the private_key and certificate' do
        #   before(:each) do
        #     pdf_path = File.join(@data_path, 'simple_form_flattened_signed.pdf')
        #     @pdf = Pdf.new(pdf_path, :keystore => @keystore)
        #   end

        #   describe '#signed?' do
        #     it 'should be true' do
        #       @pdf.should be_signed
        #     end
        #   end
        # end

        # describe 'given a pdf not signed with the private_key and certificate' do
        #   before(:each) do
        #     pdf_path = File.join(@data_path, 'simple_form_signed_by_someone_else.pdf')
        #     @pdf = Pdf.new(pdf_path, :keystore => @keystore)
        #   end

        #   describe '#signed?' do
        #     it 'should be false' do
        #       @pdf.should_not be_signed
        #     end
        #   end
        # end
      end
    end
  end

  describe '.open' do
    before(:each) do
      @save_path = File.join(@data_path, 'new_pdf.pdf')
    end

    after(:each) do
      FileUtils.rm_f(@save_path)
    end

    it 'should instaniate a new pdf and yield it to the block and then save it' do
      Pdf.open(@pdf_path, @save_path) do |pdf|
        pdf.set_fields(@filled_fields)
      end
      new_pdf = Pdf.new(@save_path)
      new_pdf.fields.should == @filled_fields
    end

    describe 'given the flatten option' do
      it 'should be saved with the flatten option' do
        Pdf.open(@pdf_path, @save_path, :flatten => true) do |pdf|
          pdf.set_fields(@filled_fields)
        end
        new_pdf = Pdf.new(@save_path)
        new_pdf.flattened_fields.should == @filled_fields
      end
    end
  end

  describe '.concatenate' do
    before(:each) do
      @pdf_1, @pdf_2 = Pdf.new(@pdf_path), Pdf.new(@pdf_path)
      @save_path = File.join(@data_path, 'new_pdf.pdf')
    end

    after(:each) do
      FileUtils.rm_f(@save_path)
    end

    it 'should return a new pdf with the pages of all the given pdfs' do
      pdf = Pdf.concatenate([@pdf_1, @pdf_2])
      pdf.number_of_pages.should == @pdf_1.number_of_pages + @pdf_2.number_of_pages
    end

    it 'should yield the pdf if given a block and then save it' do
      Pdf.concatenate([@pdf_1, @pdf_2], @save_path) do |pdf|
        pdf.number_of_pages.should == @pdf_1.number_of_pages + @pdf_2.number_of_pages
      end

      new_pdf = Pdf.new(@save_path)
      new_pdf.number_of_pages.should == @pdf_1.number_of_pages + @pdf_2.number_of_pages
    end
  end

  describe 'forwards any potential messages to the reader if it will respond' do
    it 'should respond to number_of_pages' do
      @pdf.number_of_pages.should == 1
    end

    it 'should not respond to foo_bar' do
      lambda { @pdf.foo_bar }.should raise_error NoMethodError
    end
  end

  describe '#page_size' do
    it 'should return the page size as an array of floats' do
      @pdf.page_size.should == [612.0, 792.0]
    end
  end

  describe '#page_type' do
    it 'should return the page type if it exists' do
      @pdf.page_type.should == :letter
    end
  end

  describe '#certification_level' do
    it 'should return nil for an unsigned pdf' do
      @pdf.certification_level.should == :not_certified
    end

    describe 'called on a signed pdf' do
      before(:each) do
        @pdf = Pdf.new(File.join(@data_path, 'simple_form_flattened_signed.pdf'))
      end

      it 'it should return the certification level' do
        @pdf.certification_level.should == :no_changes_allowed
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

    describe "with nonexistent field name" do
      it "should raise Pdf::NonexistentFieldError" do
        lambda { @pdf.get_field(:monkey) }.should raise_error(Pdf::NonexistentFieldError, /'monkey' field does not exist in form/)
      end
    end
  end

  describe '#set_field' do
    it 'should fill the field with given name with given value' do
      @pdf.set_field(:important_field, "I am important")
      @pdf.get_field(:important_field).should == "I am important"
    end

    it 'should return the value written to the field' do
      @pdf.set_field(:important_field, "I am important").should == 'I am important'
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

    describe "with existing field name" do
      it "should not raise an error" do
        lambda { @pdf.set_field(:important_field, 'I am important') }.should_not raise_error(Pdf::NonexistentFieldError)
      end
    end

    describe "with nonexistent field name" do
      it "should raise Pdf::NonexistentFieldError" do
        lambda { @pdf.set_field(:monkey, 'Spider') }.should raise_error(Pdf::NonexistentFieldError, /'monkey' field does not exist in form/)
      end
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
      @pdf.set_fields(@filled_fields)
      @pdf.fields.should == @filled_fields
    end

    it 'should return the set fields' do
      @pdf.set_fields(@filled_fields).should == @filled_fields
    end

    describe "with nonexistent field name" do
      it "should raise Pdf::NonexistentFieldError" do
        @filled_fields[:monkey] = "spider"
        lambda { @pdf.set_fields(@filled_fields) }.should raise_error(Pdf::NonexistentFieldError, /'monkey' field does not exist in form/)
      end
    end
  end

  describe '#save_as' do
    before(:each) do
      @new_path = File.join(@data_path, 'simple_form_new.pdf')
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

    describe 'given flatten=true' do
      it 'should save the pdf without a form' do
        @pdf.save_as(@new_path, true)

        new_pdf = Pdf.new(@new_path)
        new_pdf.should_not have_form
      end
    end
  end

  describe '#has_field?' do
    describe "with field name as symbol" do
      it 'should return true if the field exists' do
        @pdf.has_field?(:important_field).should be(true)
      end

      it 'should return false if the field does not' do
        @pdf.has_field?(:monkey).should be(false)
      end
    end

    describe "with field name as string" do
      it 'should return true if the field exists' do
        @pdf.has_field?("important_field").should be(true)
      end

      it 'should return false if the field does not' do
        @pdf.has_field?("monkey").should be(false)
      end
    end
  end

  describe '#has_form?' do
    describe 'given a pdf with a form' do
      it 'should return true' do
        @pdf.should have_form
      end
    end

    describe 'given a pdf without a form' do
      it 'should return false' do
        pdf = Pdf.new(File.join(@data_path, 'simple_form_flattened.pdf'))
        pdf.should_not have_form
      end
    end
  end

  describe 'given a pdf that we have flattened' do
    before(:each) do
      @new_pdf_path = File.join(@data_path, 'we_flattened.pdf')
      @pdf.set_fields(@filled_fields)
      @pdf.save_as(@new_pdf_path, true)
      @pdf = Pdf.new(@new_pdf_path)
    end

    after(:each) do
      FileUtils.rm_f(@new_pdf_path)
    end

    describe '#flattened_fields' do
      it 'returns a hash of field name value pairs of previous form fields' do
        @pdf.flattened_fields.should == @filled_fields
      end
    end

    describe '#has_flattened_fields?' do
      it 'should return true' do
        @pdf.should have_flattened_fields
      end
    end
  end

  describe 'given a pdf that is not flattened, or we did not flatten' do
    before(:each) do
      @pdf = Pdf.new(File.join(@data_path, 'simple_form_flattened.pdf'))
    end

    describe '#flattened_fields' do
      it 'should return an empty hash' do
        @pdf.flattened_fields.should == {}
      end
    end

    describe '#has_flattened_fields' do
      it 'should be false' do
        @pdf.should_not have_flattened_fields
      end
    end
  end

  # set_field returns some error if the form field is incorrect (e.g. setting a checkbox with something silly like 'monkey' or 'true' instead of 'Yes'
  # save_as returns *UNTESTED* if the PDF form is not valid
end

end
