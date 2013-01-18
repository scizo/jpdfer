require 'java'
require 'stringio'
require 'json'
require 'nokogiri'

module Jpdfer
  ROOT = File.expand_path('..', File.dirname(__FILE__))
end

require File.expand_path('jars/itextpdf-5.1.1.jar', Jpdfer::ROOT)
require File.expand_path('jars/bcprov-jdk16-146.jar', Jpdfer::ROOT)
require File.expand_path('jars/bctsp-jdk16-146.jar', Jpdfer::ROOT)
require File.expand_path('jars/bcmail-jdk16-146.jar', Jpdfer::ROOT)

require 'jpdfer/split'
require 'jpdfer/pdf'
require 'jpdfer/key_store'
require 'jpdfer/version'
