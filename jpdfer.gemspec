# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jpdfer/version"

Gem::Specification.new do |s|
  s.name = "jpdfer"
  s.version = Jpdfer::VERSION
  s.authors = ["Scott Nielsen", "David Brady"]
  s.email = "scottnielsen5@gmail.com"
  s.homepage = "http://github.com/scizo/jpdfer"
  s.summary = "Read and write PDF forms in JRuby"
  s.description = "Ruby-style wrapper in JRuby for reading and writing PDF forms"

  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "json-jruby"

  s.add_development_dependency "rspec"

  # ruby -rpp -e "pp (['README.rdoc'] + Dir['{{jars,lib,spec}/**/*.{jar,rdoc,,rb}}']).sort"
  s.files = [
    "README.rdoc",
    "jars/bcmail-jdk16-146.jar",
    "jars/bcprov-jdk16-146.jar",
    "jars/bctsp-jdk16-146.jar",
    "jars/itextpdf-5.1.1.jar",
    "lib/jpdfer.rb",
    "lib/jpdfer/key_store.rb",
    "lib/jpdfer/pdf.rb",
    "lib/jpdfer/version.rb"
  ]
  # ruby -rpp -e "pp (Dir['{{spec}/**/*.{rb,ks,pdf}}']).sort"
  s.test_files = [
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
  s.require_paths = ["lib"]

  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = []
end
