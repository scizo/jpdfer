class KeyStore
  class ConfigurationError < Exception; end
  module J
    include_package "java.io"
    include_package "java.security"
    include_package "java.lang"
  end

  def initialize(keystore_path, _alias, password)
    @alias, @password = _alias, password
    @keystore = J::KeyStore::getInstance(J::KeyStore::getDefaultType())
    @keystore.load(J::FileInputStream.new(keystore_path), J::String.new(@password).toCharArray)
  end

  def private_key
    @keystore.getKey(@alias, java.lang.String.new(@password).toCharArray)
  end

  def certificate_chain
    @keystore.getCertificateChain(@alias)
  end
end
