require 'java'
require 'stringio'
require 'json'
require 'nokogiri'

module Jpdfer
  ROOT=File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

require File.join(Jpdfer::ROOT, 'jars', 'itextpdf-5.1.1.jar')
require File.join(Jpdfer::ROOT, 'jars', 'bcprov-jdk16-146.jar')
require File.join(Jpdfer::ROOT, 'jars', 'bctsp-jdk16-146.jar')
require File.join(Jpdfer::ROOT, 'jars', 'bcmail-jdk16-146.jar')

require File.join(Jpdfer::ROOT, 'lib', 'jpdfer', 'pdf')
require File.join(Jpdfer::ROOT, 'lib', 'jpdfer', 'key_store')
