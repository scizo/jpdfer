JPDFER_ROOT=File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'java'
require 'stringio'
require 'json'
require 'nokogiri'
require File.join(JPDFER_ROOT, 'jars', 'itextpdf-5.1.1.jar')
require File.join(JPDFER_ROOT, 'jars', 'bcprov-jdk16-146.jar')
require File.join(JPDFER_ROOT, 'jars', 'bctsp-jdk16-146.jar')
require File.join(JPDFER_ROOT, 'jars', 'bcmail-jdk16-146.jar')

require File.join(JPDFER_ROOT, 'lib', 'jpdfer', 'pdf')
require File.join(JPDFER_ROOT, 'lib', 'jpdfer', 'key_store')
