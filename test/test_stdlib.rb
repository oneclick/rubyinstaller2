require "minitest/autorun"

class TestStdlib < Minitest::Test
  def test_bigdecimal
    require "bigdecimal"
    BigDecimal
  end

  def test_coverage
    require "coverage"
    Coverage
  end

  def test_date
    require "date"
    Date
  end

  def test_digest
    require "digest"
    Digest
  end

  def test_etc
    require "etc"
    Etc
  end

  def test_fcntl
    require "fcntl"
    Fcntl
  end

  def test_fiber
    require "fiber"
    Fiber.current
  end

  def test_fiddle
    require "fiddle"
    Fiddle
  end

  def test_gdbm
    require "gdbm"
    GDBM
  end

  def test_nkf
    require "nkf"
    NKF
  end

  def test_objspace
    require "objspace"
    ObjectSpace
  end

  def test_openssl
    require "openssl"
    OpenSSL
  end

  def test_pathname
    require "pathname"
    Pathname
  end

  def test_psych
    require "psych"
    Psych
  end

  def test_ripper
    require "ripper"
    Ripper
  end

  def test_sdbm
    require "sdbm"
    SDBM
  end

  def test_socket
    require "socket"
    Socket
  end

  def test_stringio
    require "stringio"
    StringIO
  end

  def test_strscan
    require "strscan"
    StringScanner
  end

  def test_win32ole
    require "win32ole"
    WIN32OLE
  end

  def test_zlib
    require "zlib"
    Zlib
  end
end
