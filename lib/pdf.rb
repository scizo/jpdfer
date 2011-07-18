# High-level/convenience wrapper class for a PDF document.
JPDFER_ROOT=File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'java'
require File.join(JPDFER_ROOT, 'jars', 'itextpdf-5.1.1.jar')
require 'stringio'

# PDF Document with a form that can be read, filled, and saved.
class Pdf
  class NonexistentFieldError < Exception; end
  class ReadOnlyError < Exception; end
  include_package "com.itextpdf.text.pdf"
  include_package "java.io"

  def initialize(path)
    @data = File.read(path)
    @output_buffer = StringIO.new
    reader = PdfReader.new(@data.to_java_bytes)
    @stamper = PdfStamper.new(reader, @output_buffer.to_outputstream)
    @saved = false
  end

  # Writes PDF to +path+. If +flatten+ is true, also flattens the form
  # so that the form is printed on the PDF document but the form is no
  # longer editable.
  #
  # Once a this has been called the PDF becomes read-only and any
  # subsequent calls to +save_as+, +set_field+, or +set_fields+
  # will raise an ReadOnlyError.
  #
  # save_as returns *UNTESTED* if the PDF form is not valid
  def save_as(path, flatten=false)
    raise ReadOnlyError.new("Cannot save a previously saved pdf") if @saved
    @saved = true
    @stamper.setFormFlattening(flatten)
    @stamper.close
    File.open(path, 'wb') do |file|
      file.write(@output_buffer.string)
    end
  end

  # Returns fields defined in this PDF form and their values, if any.
  # fields returns an empty hash if PDF document does not contain a form
  def fields
    form = @stamper.getAcroFields
    h = {}
    form.getFields.each_pair do |name, value|
      h[name.to_sym] = form.getField(name)
    end
    h
  end

  # Returns value of named field.
  #
  # Raises Pdf::NonexistentFieldError if field does not exist.
  # +name+:: Symbol name of field to retrieve
  def get_field(name)
    raise NonexistentFieldError.new("'#{name}' field does not exist in form") unless has_field?(name)
    @stamper.getAcroFields.getField(name.to_s)
  end

  # Sets named field. set_field returns value set.
  #
  # Raises Pdf::NonexistentFieldError if field does not exist.
  # +name+: Symbol naming the field to write
  def set_field(name, value)
    raise ReadOnlyError.new('Previously saved pdfs are read-only') if @saved
    name = name.to_sym
    raise NonexistentFieldError.new("'#{name}' field does not exist in form") unless has_field?(name)
    @stamper.getAcroFields.setField(name.to_s, value)
    value
  end

  # Sets many fields at once. Returns the hash of fields set (should
  # always be equal to given set of fields).
  #
  # Raises Pdf::NonexistentFieldError if any field does not exist.
  # +fields+:: A hash of :key => "value" pairs.
  def set_fields(fields)
    fields.each_pair do |name, value|
      set_field(name, value)
    end
    fields
  end

  # true if field +name+ exists in form
  #
  # +name+:: Field name as Symbol (or String)
  def has_field?(name)
    fields.key?(name.to_sym)
  end

  # true if the receiving Pdf instance has a form
  def has_form?
    @stamper.getAcroFields.getFields.size > 0
  end
end
