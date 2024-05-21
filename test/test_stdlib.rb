#frozen_string_literal: true
require "minitest/autorun"

class TestStdlib < Minitest::Test
  std_lib = [
    %w[ bigdecimal  BigDecimal    ],
    %w[ coverage    Coverage      ],
    %w[ cgi         CGI           ],
    %w[ date        Date          ],
    %w[ digest      Digest        ],
    %w[ etc         Etc           ],
    %w[ fcntl       Fcntl         ],
    %w[ fiber       Fiber         ],
    %w[ fiddle      Fiddle        ],
    %w[ json        JSON          ],
    %w[ nkf         NKF           ],
    %w[ objspace    ObjectSpace   ],
    %w[ openssl     OpenSSL::OPENSSL_VERSION ],
    %w[ pathname    Pathname      ],
    %w[ psych       Psych::LIBYAML_VERSION   ],
    %w[ racc/cparse Racc::Parser  ],
    %w[ ripper      Ripper        ],
    %w[ socket      Socket        ],
    %w[ stringio    StringIO      ],
    %w[ strscan     StringScanner ],
    %w[ win32ole    WIN32OLE      ],
    %w[ zlib        Zlib::ZLIB_VERSION ]
  ]

  std_lib.each do |d|
    self.class_eval <<-CODE
      def test_#{d[0].gsub('/', '_')}
        require '#{d[0]}'
        #{d[1]}
      end
    CODE
  end

  # Make sure ruby is linked to libgmp
  def test_gmp
    assert_match(/GMP \d/, Integer::GMP_VERSION)
  end

  # SDBM was removed in ruby > 2.7
  if RUBY_VERSION =~ /^2\.[4567]\./
    def test_sdbm
      require "sdbm"
      SDBM
    end
  end

  # DBM and GDBM were removed in ruby > 3.0
  if RUBY_VERSION =~ /^2\.[4567]|^3\.0\./
    def test_dbm
      require "dbm"
      DBM
    end
    def test_gdbm
      require "gdbm"
      GDBM::VERSION
    end
  end

  # Make sure we're using the expected OpenSSL version
  def test_openssl_version
    require "openssl"

    case RUBY_VERSION
      when /^2\.[34]\./
        assert_match(/OpenSSL 1\.0\./, OpenSSL::OPENSSL_VERSION)
        assert_match(/OpenSSL 1\.0\./, OpenSSL::OPENSSL_LIBRARY_VERSION)
      when /^2\.[567]\.|^3\.[01]\./
        assert_match(/OpenSSL 1\.1\./, OpenSSL::OPENSSL_VERSION)
        assert_match(/OpenSSL 1\.1\./, OpenSSL::OPENSSL_LIBRARY_VERSION)
      else
        assert_match(/OpenSSL 3\./, OpenSSL::OPENSSL_VERSION)
        assert_match(/OpenSSL 3\./, OpenSSL::OPENSSL_LIBRARY_VERSION)
        assert_match(/OpenSSL 3\./, OpenSSL::OPENSSL_LIBRARY_VERSION)
    end
  end

  def test_openssl_provider
    # ruby-3.2 has OpenSSL-3.x which supports provider API, but the ruby C-ext is too old there
    return if RUBY_VERSION =~ /^2\.[34567]\.|^3\.[012]\./
    require "openssl"

    OpenSSL::Provider.load("legacy")
    cipher = OpenSSL::Cipher.new("RC4")
    assert_equal "RC4", cipher.name
  end
end
