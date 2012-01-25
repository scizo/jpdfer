module Jpdfer

  class KeyStore
    JavaFileInputStream = java.io.FileInputStream
    JavaKeyStore = java.security.KeyStore
    JavaString = java.lang.String

    def initialize(keystore_path, _alias, password)
      @alias, @password = _alias, password
      @keystore = JavaKeyStore::getInstance(JavaKeyStore::getDefaultType())
      @keystore.load(JavaFileInputStream.new(keystore_path), JavaString.new(@password).toCharArray)
    end

    def private_key
      @keystore.getKey(@alias, java.lang.String.new(@password).toCharArray)
    end

    def certificate_chain
      @keystore.getCertificateChain(@alias)
    end
  end

end
