module RubyInstaller
module Build # Use for: Build, Runtime
module Components
class Msys2 < Base
  def description
    "MSYS2 base installation"
  end

  def needed?(try_kill: true)
    begin
      autorebase

      if msys.with_msys_apps_enabled(if_no_msys: :raise) { run_verbose("sh", "-lc", "true") }
        puts "MSYS2 seems to be " + green("properly installed")
        false
      else
        if try_kill
          # Already running MSYS2 processes might interference with our MSYS2 through shared memory.
          kill_all_msys2_processes
          return needed?(try_kill: false)
        end
        true
      end
    rescue Msys2Installation::MsysNotFound
      puts "MSYS2 seems to be " + red("unavailable")
      true
    end
  end

  def execute(args)
    hash = ENV['MSYS2_VERSION'] ? nil : msys2_download_hash
    downloaded_path = download(msys2_download_uri, hash)

    puts "Run the MSYS2 installer ..."
    if run_verbose(downloaded_path) && msys.with_msys_apps_enabled { run_verbose("sh", "-lc", "true") }
      puts green(" Success")
    else
      puts red(" Failed")
      raise "MSYS2 installer failed"
    end
  end

  private

  MSYS2_VERSION = ENV['MSYS2_VERSION'] || "20190524"
  MSYS2_URI = "http://repo.msys2.org/distrib/<arch>/msys2-<arch>-#{MSYS2_VERSION}.exe"

  MSYS2_I686_SHA256 = "c5a1881f7ac5a0449fe9b30d3140111a88072727f510c4a66bfa905f8c78e839"
  MSYS2_X86_64_SHA256 = "2dacadcc70cc122054e60914cbc6b689f685bef5713915a90f4185dd9da7954e"

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
end
end
end
end
