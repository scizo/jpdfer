require 'spec_helper'


module Jpdfer
# IMPORTANT: These are model/unit specs! Test in isolation as much as possible!
describe Pdf do
  before(:each) do
    @data_path = File.join(ROOT, 'spec', 'data')
    @pdf_path = File.join(@data_path, 'simple_form.pdf')
    @pdf = Pdf.new(@pdf_path)
  end

  describe '.new' do
    it 'should create new pdf' do
      @pdf.should_not be_nil
    end
  end
end

end
