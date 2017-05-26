module RubyInstaller
module Build
class CaCertFile
  attr_reader :content

  def initialize(content=nil)
    content ||= download_ssl_cacert_pem

    @content = content
  end

  MOZILLA_CA_CSV_URI = "https://ccadb-public.secure.force.com/mozilla/IncludedCACertificateReportPEMCSV"

  def download_ssl_cacert_pem
    require 'open-uri'
    require 'csv'
    require 'openssl'
    require 'stringio'

    csv_data = OpenURI.open_uri(MOZILLA_CA_CSV_URI)

    fd = StringIO.new
    fd.write <<-EOT
##
## Bundle of CA Root Certificates
##
## Certificate data from Mozilla as of: #{Time.now.utc}
##
## This is a bundle of X.509 certificates of public Certificate Authorities (CA).
## These were automatically extracted from Mozilla's root certificates CSV file
## downloaded from:
## #{MOZILLA_CA_CSV_URI}
##
## Further information about the CA certificate list can be found:
## https://wiki.mozilla.org/CA:IncludedCAs
##
## This file is used as default CA certificate list for Ruby.
## Conversion done with rubyinstaller-build version #{RubyInstaller::Build::GEM_VERSION}.
##
EOT

    CSV.parse(csv_data, headers: true).select do |row|
      row["Trust Bits"].split(";").include?("Websites")
    end.map do |row|
      pem = row["PEM Info"]
      OpenSSL::X509::Certificate.new(pem.gsub(/\A'/,"").gsub(/'\z/,""))
    end.sort_by do |cert|
      [cert.subject.to_a.sort, -cert.serial.to_i]
    end.each do |cert|
      sj = "#{ OpenSSL::X509::Name.new(cert.subject.to_a.sort) } - #{cert.serial.to_i}"
      fd.write "\n#{ sj }\n#{ "=" * sj.length }\n#{ cert.to_pem }\n"
    end

    fd.string
  end

  def remove_comments(filecontent)
    filecontent.gsub(/^##.*$/, "")
  end

  def ==(other)
    remove_comments(content) == remove_comments(other.content)
  end
end
end
end
