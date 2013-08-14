require 'jpdfer/page_sizes'
require 'jpdfer/page_range_utilities'
# High-level/convenience wrapper class for a PDF document.

module Jpdfer

  # PDF Document with a form that can be read, filled, and saved.
  class Pdf
    class NonexistentFieldError < StandardError; end
    class ReadOnlyError < StandardError; end
    include_class Java::com.itextpdf.text.Element
    include_class Java::com.itextpdf.text.Font
    include_class Java::com.itextpdf.text.Font::FontFamily
    include_class Java::com.itextpdf.text.Image
    include_class Java::com.itextpdf.text.Phrase
    include_class Java::java.net.URL
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

    # A convenience method which concatenates the pages of several pdfs into one pdf. If a block is given,
    # the new pdf is yielded and saved to +save_path+ after the block has been called.
    #
    # The available options are :keystore and :flatten.
    #
    # Returns the created pdf. If no block is given, save_as must be called to save the pdf.
    def self.concatenate(pdfs, save_path=nil, options={})
      output_buffer = StringIO.new
      flatten = options.delete(:flatten)
      concatenator = PdfCopyFields.new output_buffer.to_outputstream

      pdfs.each do |pdf, page_range|
        if page_range
          PageRangeUtilities::normalize_page_range(page_range).each do |pages|
            # We need to help jruby convert Fixnum to java.lang.Integer. It defaults to java.lang.Long
            pages = pages.map {|page| Java::JavaLang::Integer.new page}
            concatenator.addDocument pdf.reader, pages
          end
        else
          concatenator.addDocument pdf.reader
        end
      end
      concatenator.close

      pdf = new(StringIO.new(output_buffer.string), options)
      if block_given?
        yield pdf
        pdf.save_as(save_path, flatten)
      end
      pdf
    end

    # A convenience method which initializes a new pdf. If a block is given,
    # the new pdf is yielded and saved to +save_path+ after the block has been called.
    #
    # The options accept :flatten and :keystore.
    #
    # Returns the created pdf. If no block is given, save_as must be called to save the pdf.
    def self.open(pdf_path, save_path=nil, options={})
      flatten = options.delete(:flatten)
      pdf = new(pdf_path, options)
      if block_given?
        yield pdf
        pdf.save_as(save_path, flatten)
      end
      pdf
    end

    # Currently the only option is :keystore
    def initialize(file_or_path, options = {})
      data = file_or_path.read if file_or_path.respond_to?(:read)
      data ||= File.read file_or_path

      @keystore = options[:keystore]

      init(data)
    end

    # Instances of Pdf forward any possible unknown method calls to the underlying
    # iText PdfReader instance
    def method_missing(method, *args)
      return @reader.send(method, *args) if @reader.respond_to? method
      super
    end

    # Returns an independent instance of the underlying iText PdfReader.
    def reader
      PdfReader.new @data.to_java_bytes
    end

    # Returns a string representation of the Pdf object
    def inspect
      "<Jpdfer::Pdf @reader=#{@reader}, @stamper=#{@stamper}>"
    end

    # Writes PDF to +path+. If +flatten+ is true, also flattens the form
    # so that the form is printed on the PDF document but the form is no
    # longer editable.
    #
    # save_as returns *UNTESTED* if the PDF form is not valid
    def save_as(path, flatten=false)
      if flatten
        metadata = self.class.create_flatten_fields_xml(fields)
        @stamper.setXmpMetadata metadata.to_java_bytes
      end

      @stamper.setFormFlattening(flatten)
      @stamper.close

      File.open(path, 'wb') do |file|
        file.write(@output_buffer.string)
      end

      init(@output_buffer.string)
    end

    # Returns the page size of the pdf as [width (Float), height (Float)]
    def page_size
      page_size = @reader.crop_box(1)
      if @reader.page_rotation(1) % 180 == 0
        [page_size.width, page_size.height]
      else
        [page_size.height, page_size.width]
      end
    end

    # Returns the page type of the pdf or :unknown
    # See Jpdfer::PAGES_SIZES
    def page_type
      PAGE_SIZES.fetch(page_size, :unknown)
    end

    # Returns fields defined in this PDF form and their values, if any.
    # fields returns an empty hash if PDF document does not contain a form
    def fields
      form = @stamper.getAcroFields
      form.getFields.each_with_object({}) do |(name, value), fields|
        fields[name.to_sym] = form.getField(name)
      end
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
    # +name+: Symbol naming the field to write
    def set_field(name, value)
      name = name.to_sym
      raise NonexistentFieldError.new("'#{name}' field does not exist in form") unless has_field?(name)
      @stamper.getAcroFields.setField(name.to_s, value.to_s)
      value
    end

    # Sets many fields at once. Returns the hash of fields set (should
    # always be equal to given set of fields).
    #
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
      metadata_string = String.from_java_bytes @reader.getMetadata
      description_text = self.class.description_from_metadata_xml(metadata_string)
      begin
        metadata = JSON(description_text)
        flattened_fields = metadata.key?('jpdfer_flattened_fields') ? metadata['jpdfer_flattened_fields'] : {}
      rescue JSON::ParserError
        flattened_fields = {}
      end
      flattened_fields.each_with_object({}) do |(name, value), fields|
        fields[name.to_sym] = value
      end
    end

    # Adds viewer preferences to the pdf.
    # For all possible key value pairs see:
    # http://api.itextpdf.com/itext/com/itextpdf/text/pdf/interfaces/PdfViewerPreferences.html#addViewerPreference(com.itextpdf.text.pdf.PdfName, com.itextpdf.text.pdf.PdfObject)
    #
    # keys and values can be passed in as lower or upper case symbols or strings
    def add_viewer_preference(key, value)
      converted_key = PdfName.const_get(key.upcase) rescue nil
      converted_key ||= PdfBoolean.const_get(key.upcase)

      converted_value = PdfName.const_get(value.upcase) rescue nil
      converted_value ||= PdfBoolean.const_get(value.upcase)

      @stamper.add_viewer_preference(converted_key, converted_value)
    end

    # true if the receiving Pdf instance was previously flattened with jpdfer
    def has_flattened_fields?
      flattened_fields.size > 0 ? true : false
    end

    # Returns the certification level of the pdf
    def certification_level
      case @reader.getCertificationLevel
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

    # Sets the reason for the signature on the pdf
    def set_signature_reason(reason)
      @stamper.getSignatureAppearance.setReason(reason)
    end

    # Sets the location of the signature on the pdf
    def set_signature_location(location)
      @stamper.getSignatureAppearance.setLocation(location)
    end

    # Adds the image at +image_path+ to the given +page+, at coordinates +x+ and +y+
    def add_image(image_path, page, x, y, scale=1.0)
      raise ReadOnlyError.new('Previously saved pdfs are read-only') if @saved
      canvas = @stamper.getOverContent(page)
      image = Image.getInstance(image_path)
      image.setAbsolutePosition(x, y)
      image.scalePercent(scale * 100)
      canvas.addImage(image, false)
    end

    # Add watermark text to all pages at coordinates +x+ and +y+
    #
    #
    # options:
    #
    #   :x The placement of the watermark on the x-axis
    #     Default: The center of the pdf
    #
    #   :y The placement of the watermark on the y-axis
    #     Default: The center of the pdf
    #
    #   :font should be an instance of com.itextpdf.text.Font to be used for the watermark.
    #      Default: Helvetica Bold 132pt 0.9 Gray
    #
    #   :rotation is an angle given in degrees that will rotate the watermark.
    #      Default: 45
    #
    #   :alignment one of the com.itextpdf.text.Element alignment values
    #     Default: ALIGN_CENTER
    def add_watermark(text, options={})
      raise ReadOnlyError.new('Previously saved pdfs are read-only') if @saved

      x = options[:x] || @reader.crop_box(1).width / 2
      y = options[:y] || @reader.crop_box(1).height / 2
      alignment = options[:alignment] || Element::ALIGN_CENTER
      phrase = Phrase.new(text, options[:font] || default_watermark_font)
      rotation = options[:rotation] || 45

      1.upto(@reader.getNumberOfPages).each do |page|
        canvas = @stamper.getUnderContent(page)
        ColumnText.showTextAligned(canvas, alignment, phrase, x, y, rotation)
      end
    end

    # Replaces any javascript currently attached to the page with
    # the contents of +script+
    #
    # Returns +script+
    def javascript=(script)
      @stamper.addJavaScript(script)
      script
    end

    private

    def init(data)
      @data = data
      @reader = PdfReader.new(data.to_java_bytes)
      @output_buffer = StringIO.new
      @stamper = create_stamper
    end

    def default_watermark_font
      Font.new \
        FontFamily::HELVETICA,
        132,
        Font::BOLD,
        GrayColor.new(0.90)
    end

    def create_stamper
      if @keystore
        stamper = PdfStamper.createSignature(@reader, @output_buffer.to_outputstream, 0)
        key, certificate_chain = @keystore.private_key, @keystore.certificate_chain
        # TODO: Should not always be self-signed
        signature_type = Pdf::PdfSignatureAppearance::SELF_SIGNED
        stamper.getSignatureAppearance.setCrypto(key, certificate_chain, nil, signature_type)
      else
        stamper = PdfStamper.new(@reader, @output_buffer.to_outputstream)
      end
      stamper
    end
  end
end
