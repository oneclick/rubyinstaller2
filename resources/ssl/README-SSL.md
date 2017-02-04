RubyInstaller2 - SSL/TLS configuration
======================================

RubyInstaller2 is packaged with a predefined list of trusted certificate authorities (CAs).
This list is stored in the file `<install-path>/ssl/cert.pem` .
It contains the certificates of the [default list of the Mozilla Foundation](https://wiki.mozilla.org/CA:IncludedCAs) .
The file `cert.pem` is loaded when `require "openssl"` is executed.
New releases of the RubyInstaller2 update the CA list to the latest version at the release date.
`cert.pem` will be overwritten while the installation of RubyInstaller2.

Use of an alternative CA list
-----------------------------

The default CA list can be overwritten by the environment variable `SSL_CERT_FILE` .
It should point to the absolute path of a valid pem file.
Setting this variable disabled the list bundled with RubyInstaller2.

Addition of certificate to the default CA list
----------------------------------------------

Additional certificates shall be stored in `<install-path>/ssl/certs/` in pem format.
In order to activate the certificate(s) for CA lookup, the certificate must use a OpenSSL-hashed filename.
Run `<install-path>/ssl/certs/c_rehash.rb` to generate these hash files.
Usually double clicking `c_rehash.rb` does the trick.
