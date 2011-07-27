# High-level/convenience wrapper class for a PDF document.


# PDF Document with a form that can be read, filled, and saved.
class Pdf
  class NonexistentFieldError < Exception; end
  class ReadOnlyError < Exception; end
  include_package "com.itextpdf.text.pdf"
  include_package "com.itextpdf.text.xml.xmp"

  def self.create_flatten_fields_xml(fields)
    schema = DublinCoreSchema.new
    schema.addDescription(JSON({'jpdfer_flattened_fields' => fields}))
    metaout = StringIO.new
    xmpwriter = XmpWriter.new(metaout.to_outputstream)
    xmpwriter.addRdfDescription(schema)
    xmpwriter.close
    metaout.string
  end

  def self.description_from_metadata_xml(metadata_string)
    metadata_string.gsub!(/<\?.*?\?>/, '')
    namespaces = {
      "xmlns:x"   => "adobe:ns:meta/",
      "xmlns:rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "xmlns:dc"  => "http://purl.org/dc/elements/1.1/"
    }
    root_node = Nokogiri::XML.parse(metadata_string)
    descriptions = root_node.xpath('.//dc:description//rdf:li/text()', namespaces)
    descriptions.count > 0 ? descriptions.first.text : ""
  end

  # Currently the only option is :keystore
  def initialize(path, options = {})
    @data = File.read(path)
    @output_buffer = StringIO.new
    reader = PdfReader.new(@data.to_java_bytes)
    @stamper = create_stamper(reader, options[:keystore])
    @saved = false
  end

  # helper method for initialize not ment to be used publicly
  def create_stamper(reader, keystore = nil)
    if keystore
      stamper = PdfStamper.createSignature(reader, @output_buffer.to_outputstream, "\0".ord)
      key, certificate_chain = keystore.private_key, keystore.certificate_chain
      signature_type = Pdf::PdfSignatureAppearance::SELF_SIGNED
      stamper.getSignatureAppearance.setCrypto(key, certificate_chain, nil, signature_type)
    else
      stamper = PdfStamper.new(reader, @output_buffer.to_outputstream)
    end
    stamper
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
    if flatten
      metadata = self.class.create_flatten_fields_xml(fields)
      @stamper.setXmpMetadata metadata.to_java_bytes
    end
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

  # Returns field names and values that were written to a
  # form in this pdf before flattening.
  # Returns an empty hash if there are not any.
  def flattened_fields
    reader = @stamper.reader
    metadata_string = String.from_java_bytes reader.getMetadata
    description_text = self.class.description_from_metadata_xml(metadata_string)
    begin
      metadata = JSON(description_text)
      _flattened_fields = metadata.key?('jpdfer_flattened_fields') ? metadata['jpdfer_flattened_fields'] : {}
    rescue JSON::ParserError
      _flattened_fields = {}
    end
    h = {}
    _flattened_fields.each_pair do |name, value|
      h[name.to_sym] = value
    end
    h
  end

  # true if the receiving Pdf instance was previously flattened with jpdfer
  def has_flattened_fields?
    flattened_fields.size > 0 ? true : false
  end

  # Returns the certification level of the pdf
  def certification_level
    case @stamper.reader.getCertificationLevel
    when PdfSignatureAppearance::CERTIFIED_FORM_FILLING
      level = :form_filling
    when PdfSignatureAppearance::CERTIFIED_FORM_FILLING_AND_ANNOTATIONS
      level = :form_filling_and_annotations
    when PdfSignatureAppearance::CERTIFIED_NO_CHANGES_ALLOWED
      level = :no_changes_allowed
    when PdfSignatureAppearance::NOT_CERTIFIED
      level = :not_certified
    end
    level
  end

  # Set the certification level on a pdf initialized with an optional keystore
  #
  # *level* must be one of :form_filling, :form_filling_and_annotations,
  # :no_changes_allowed, :not_certified
  def set_certification_level(level)
    case level
    when :form_filling
      certification_level = PdfSignatureAppearance::CERTIFIED_FORM_FILLING
    when :form_filling_and_annotations
      certification_level = PdfSignatureAppearance::CERTIFIED_FORM_FILLING_AND_ANNOTATIONS
    when :no_changes_allowed
      certification_level = PdfSignatureAppearance::CERTIFIED_NO_CHANGES_ALLOWED
    when :not_certified
      level = PdfSignatureAppearance::NOT_CERTIFIED
    end
    @stamper.getSignatureAppearance.setCertificationLevel(certification_level)
  end

end
