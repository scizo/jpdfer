JPDFER_ROOT=File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'java'
require File.join(JPDFER_ROOT, 'jars', 'itextpdf-5.1.1.jar')
require 'stringio'
require 'json'
require 'nokogiri'

require File.join(JPDFER_ROOT, 'lib', 'jpdfer', 'pdf')
