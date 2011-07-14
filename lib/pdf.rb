# High-level/convenience wrapper class for a PDF document.
JPDFER_ROOT=File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'java'
require File.join(JPDFER_ROOT, 'jars', 'itextpdf-5.1.1.jar')

class Pdf
  module J
    include_package "com.itextpdf.text.pdf"
    include_package "java.io"
  end


  def initialize(path)
    @data = File.read(path)
    @reader = J::PdfReader.new(@data.to_java_bytes)
    @changes = {}
  end

  def save_as(path)
    File.open(path, 'wb') do |file|
      stamper = J::PdfStamper.new(@reader, file.to_outputstream)
      form = stamper.getAcroFields
      @changes.each_pair do |name, value|
        form.setField(name.to_s, value)
      end
      stamper.close
      # File.open(path, 'wb') { |file| file.write @data }
    end
  end

  # Returns fields defined in this PDF form and their values, if any.
  def fields
    form = @reader.getAcroFields
    h = {}
    form.getFields.each_pair do |name, value|
      h[name.to_sym] = form.getField(name)
    end
    h.merge(@changes)
  end

  def get_field(name)
    @changes[name] || @reader.getAcroFields.getField(name.to_s)
  end

  def set_field(name, value)
    @changes[name] = value
  end

end
