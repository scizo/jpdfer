# High-level/convenience wrapper class for a PDF document.
class Pdf
  def initialize(path)
    @data = File.read(path)
  end

  def save_as(path)
    File.open(path, 'wb') { |file| file.write @data }
  end

  # Returns fields defined in this PDF form and their values, if any.
  def fields
    {
      :important_field => '',
      :unimportant_field => '',
      :semiimportant_field => '',
      :tuesday_field => '',
      :must_not_be_left_field => ''
    }
  end
end
