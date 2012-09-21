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

  s.platform = 'java'

  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "json-jruby"

  s.add_development_dependency "rspec"

  s.files = ['README.rdoc'] + Dir['{jars,lib}/**/*.{jar,rdoc,rb}']
  s.test_files = Dir['spec/**/*.{rb,ks,pdf}']

  s.require_paths = ["lib"]

  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = []
end
