Gem::Specification.new do |s|
  s.name = "jpdfer"
  s.version = "0.9.0"
  s.date = "2011-07-15"
  s.summary = "Ruby-style wrapper in JRuby for reading and writing PDF forms"
  s.email = "scottnielsen5@gmail.com"
  s.homepage = "http://github.com/scizo/jpdfer"
  s.description = " Read and write PDF forms in JRuby"
  s.authors = ["Scott Nielsen", "David Brady"]

  # ruby -rpp -e "pp (['README.rdoc'] + Dir['{{examples,jars,lib,protocol,spec}/**/*.{jar,rdoc,json,rb,txt,xml,yml}}'] + Dir['bin/*']).sort"
  s.files = [
    "README.rdoc",
    "jars/itextpdf-5.1.1.jar",
    "lib/pdf.rb",
    "spec/acceptance/pdf_acceptance_spec.rb",
    "spec/lib/pdf_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = []
end
