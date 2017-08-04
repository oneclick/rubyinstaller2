#frozen_string_literal: true
require "minitest/autorun"
require "net/https"
require "uri"
require "openssl"

class TestSslCacerts < Minitest::Test
  EXTERNAL_HTTPS = "https://torproject.org"

  def test_https_external
    uri = URI(EXTERNAL_HTTPS)
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |https|
      https.head('/').code
    end
    assert_equal("302", res)
  end
end
