RubyInstaller2 - SSL/TLS configuration
======================================

RubyInstaller2 is packaged with a predefined list of trusted certificate authorities (CAs).
This list is stored in the file `<install-path>/ssl/cert.pem` .
It contains the certificates of the [default list of the Mozilla Foundation](https://wiki.mozilla.org/CA/Included_Certificates) .
The file `cert.pem` is loaded when `require "openssl"` is executed.
New releases of the RubyInstaller2 update the CA list to the latest version at the release date.
`cert.pem` shouldn't be modified manually, because it will be overwritten by updates of RubyInstaller2.
Instead add certificates as described below.

Use of an alternative CA list
-----------------------------

The default CA list can be overwritten by the environment variable `SSL_CERT_FILE` .
It should point to the absolute path of a valid pem file.
Setting this variable disables the CA list bundled with RubyInstaller2.

Addition of certificate to the default CA list
----------------------------------------------

Additional certificates shall be stored in `<install-path>/ssl/certs/<yourfile>.pem` in pem format.
Each pem file may contain several certificates.
The pem files must be activated for CA lookup by using a OpenSSL-hashed filename.
There is a helper script in `<install-path>/ssl/certs/c_rehash.rb` to generate these hash files.
Just double click `c_rehash.rb` to activate all pem files in the directory.
