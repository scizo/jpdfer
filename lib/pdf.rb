class Pdf
  def initialize(path)
    @data = File.read(path)
  end

  def save_as(path)
    File.open(path, 'wb') { |file| file.write @data }
  end
end
