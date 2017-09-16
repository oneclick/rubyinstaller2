#frozen_string_literal: true
require "minitest/autorun"

class TestStdlib < Minitest::Test
  std_lib = [
    %w[ bigdecimal  BigDecimal    ],
    %w[ coverage    Coverage      ],
    %w[ cgi         CGI           ],
    %w[ date        Date          ],
    %w[ dbm         DBM           ],
    %w[ digest      Digest        ],
    %w[ etc         Etc           ],
    %w[ fcntl       Fcntl         ],
    %w[ fiber       Fiber         ],
    %w[ fiddle      Fiddle        ],
    %w[ gdbm        GDBM::VERSION ],
    %w[ json        JSON          ],
    %w[ nkf         NKF           ],
    %w[ objspace    ObjectSpace   ],
    %w[ openssl     OpenSSL::OPENSSL_VERSION ],
    %w[ pathname    Pathname      ],
    %w[ psych       Psych::LIBYAML_VERSION   ],
    %w[ racc/cparse Racc::Parser  ],
    %w[ ripper      Ripper        ],
    %w[ sdbm        SDBM          ],
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
    assert_match /GMP \d/, Integer::GMP_VERSION
  end
end
