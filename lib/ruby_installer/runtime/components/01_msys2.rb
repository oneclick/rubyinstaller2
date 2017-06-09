module RubyInstaller
module Runtime
module Components
class Msys2 < Base
  def description
    "MSYS2 base installation"
  end

  def needed?
    msys = Runtime.msys2_installation
    begin
      print "MSYS2 seems to be "
      msys.msys_path
      puts green("already installed")
      false
    rescue Msys2Installation::MsysNotFound
      puts red("unavailable")
      true
    end
  end

  def execute(args)
    require "open-uri"

    uri = msys2_download_uri
    filename = File.basename(uri)
    temp_path = File.join(ENV["TMP"] || ENV["TEMP"] || ENV["USERPROFILE"] || "C:/", filename)

    until check_hash(temp_path, msys2_download_hash)
      puts "Download #{yellow(uri)}\n  to #{yellow(temp_path)}"
      File.open(temp_path, "wb") do |fd|
        progress = 0
        total = 0
        params = {
          "Accept-Encoding" => 'identity',
          :content_length_proc => lambda{|length| total = length },
          :progress_proc => lambda{|bytes|
            new_progress = (bytes * 100) / total
            print "\rDownloading %s (%3d%%) " % [filename, new_progress]
            progress = new_progress
          }
        }
        OpenURI.open_uri(uri, params) do |io|
          fd << io.read
        end
        puts
      end
    end

    puts "Run the MSYS2 installer ..."
    if run_verbose(temp_path)
      puts green(" Success")
    else
      puts red(" Failed")
      raise "MSYS2 installer failed"
    end
  end

  private

  MSYS2_VERSION = ENV['MSYS2_VERSION'] || "20161025"
  MSYS2_URI = "http://repo.msys2.org/distrib/<arch>/msys2-<arch>-#{MSYS2_VERSION}.exe"

  MSYS2_I686_SHA256 = "4951a47177777a54c7ad4ac99755ba4bbdf1a0cb23a174a72d91f71dc25bcb15"
  MSYS2_X86_64_SHA256 = "2c198787ea1c4be39ff80466c4d831f8c7f06bd56d6d190bf63ede35292e344c"

  def msys2_download_uri
    arch = RUBY_PLATFORM=~/x64/ ? "x86_64" : "i686"
    MSYS2_URI.gsub(/<arch>/, arch)
  end

  def msys2_download_hash
    case RUBY_PLATFORM
      when /x64/ then MSYS2_X86_64_SHA256
      else MSYS2_I686_SHA256
    end
  end

  def check_hash(path, hash)
    if ENV['MSYS2_VERSION']
      true
    elsif !File.exist?(path)
      false
    else
      require "digest"

      print "Verify integrity of #{File.basename(path)} ..."
      res = Digest::SHA256.file(path).hexdigest == hash.downcase
      puts(res ? green(" OK") : red(" Failed"))
      res
    end
  end
end
end
end
end
