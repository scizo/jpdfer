Gem::Specification.new do |s|
  s.name = "jpdfer"
  s.version = "0.9.0"
  s.date = "2011-07-27"
  s.summary = "Ruby-style wrapper in JRuby for reading and writing PDF forms"
  s.email = "scottnielsen5@gmail.com"
  s.homepage = "http://github.com/scizo/jpdfer"
  s.description = "Read and write PDF forms in JRuby"
  s.authors = ["Scott Nielsen", "David Brady"]

  # ruby -rpp -e "pp (['README.rdoc'] + Dir['{{examples,jars,lib,protocol,spec}/**/*.{jar,rdoc,json,rb,txt,xml,yml,ks,pdf}}'] + Dir['bin/*']).sort"
  s.files = [
    "README.rdoc",
    "jars/bcmail-jdk16-146.jar",
    "jars/bcprov-jdk16-146.jar",
    "jars/bctsp-jdk16-146.jar",
    "jars/itextpdf-5.1.1.jar",
    "lib/jpdfer.rb",
    "lib/jpdfer/key_store.rb",
    "lib/jpdfer/pdf.rb",
    "spec/acceptance/jpdfer/pdf_acceptance_spec.rb",
    "spec/data/flattened.pdf",
    "spec/data/keystore.ks",
    "spec/data/simple_form.pdf",
    "spec/data/simple_form_flattened.pdf",
    "spec/data/simple_form_flattened_signed.pdf",
    "spec/data/simple_form_signed_by_someone_else.pdf",
    "spec/lib/jpdfer/pdf_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = []
end
