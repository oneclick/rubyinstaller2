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
      raise "MSYS2 installer failed.\n\nYou might download MSYS2 from the official site: https://www.msys2.org/ and run the installer manually.\nThen you can use 'ridk install' to install necessary tools and to keep MSYS2 up-to-date."
    end
  end

  private

  MSYS2_VERSION = ENV['MSYS2_VERSION'] || "20241208"
  MSYS2_URI = "https://repo.msys2.org/distrib/x86_64/msys2-x86_64-#{MSYS2_VERSION}.exe"
  MSYS2_SHA256 = "dcce4f115cdcb76453c3f0937c8c2629c3b1923f34bc2aa50fd39e9a63ade1fa"

  def msys2_download_uri
    MSYS2_URI
  end

  def msys2_download_hash
    MSYS2_SHA256
  end
end
end
end
end
