# spec_helper.rb
require 'pdf'
require 'digest/md5'
require 'fileutils'

def checksum(path)
  digest = Digest::SHA1.new
  digest << File.read(path)
end
