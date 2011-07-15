# High-level/convenience wrapper class for a PDF document.
JPDFER_ROOT=File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'java'
require File.join(JPDFER_ROOT, 'jars', 'itextpdf-5.1.1.jar')

# PDF Document with a form that can be read, filled, and saved.
class Pdf
  include_package "com.itextpdf.text.pdf"
  include_package "java.io"
  
  def initialize(path)
    @data = File.read(path)
    @reader = PdfReader.new(@data.to_java_bytes)
    @changes = {}
  end

  # Writes PDF to +path+. If +flatten+ is true, also flattens the form
  # so that the form is printed on the PDF document but the form is no
  # longer editable.
  #
  # save_as returns *UNTESTED* if the PDF form is not valid
  # save_as returns *UNTESTED* if the file cannot be written
  def save_as(path, flatten=false)
    File.open(path, 'wb') do |file|
      stamper = PdfStamper.new(@reader, file.to_outputstream)
      form = stamper.getAcroFields
      @changes.each_pair do |name, value|
        form.setField(name.to_s, value)
      end
      stamper.setFormFlattening(flatten)
      stamper.close
    end
  end

  # Returns fields defined in this PDF form and their values, if any.
  # fields returns *UNTESTED* if PDF document does not contain a form
  def fields
    form = @reader.getAcroFields
    h = {}
    form.getFields.each_pair do |name, value|
      h[name.to_sym] = form.getField(name)
    end
    h.merge(@changes)
  end

  # Returns value of named field.
  # 
  # +name+:: Symbol name of field to retrieve
  # get_field returns *UNTESTED* if field does not exist
  # get_field returns *UNTESTED* if PDF document does not contain a form
  def get_field(name)
    @changes[name] || @reader.getAcroFields.getField(name.to_s)
  end

  # Sets named field. set_field returns value. *UNTESTED*.
  # 
  # +name+: Symbol naming the field to write
  # set_field returns *UNTESTED* if field is not found
  # set_field returns *UNTESTED* if PDF document does not contain a form
  def set_field(name, value)
    @changes[name] = value
  end

  # Sets many fields at once. set_fields returns ?? *UNTESTED*.
  # 
  # +fields+:: A hash of :key => "value" pairs.
  # set_fields returns *UNTESTED* if field is not found
  # set_fields returns *UNTESTED* if PDF document does not contain a form
  def set_fields(fields)
    @changes.merge!(fields)
  end

  # TODO: def form, returns AcroFields object?
  # TODO: def has_form?, returns true if PDF has an AcroFields object

  # BUG: set_field does not validate field on PDF form. The fix is to
  # keep the PDF in an in-memory buffer and use PdfStamper to write
  # immediately to it rather than deferring changes.
end
