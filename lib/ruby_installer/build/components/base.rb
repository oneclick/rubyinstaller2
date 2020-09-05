module RubyInstaller
module Build # Use for: Build, Runtime
module Components
class Base < Rake::Task
  include Colors

  attr_accessor :task_index
  attr_writer :msys
  attr_accessor :pacman_args

  def self.depends
    []
  end

  def initialize(*_)
    @msys = nil
    enable_colors
    super
  end

  def msys
    @msys ||= BuildOrRuntime.msys2_installation
  end

  # This is extracted from https://github.com/larskanis/shellwords
  def shell_escape(str)
    str = str.to_s

    # An empty argument will be skipped, so return empty quotes.
    return '""' if str.empty?

    str = str.dup

    str.gsub!(/((?:\\)*)"/){ "\\" * ($1.length*2) + "\\\"" }
    if str =~ /\s/
      str.gsub!(/(\\+)\z/){ "\\" * ($1.length*2) }
      str = "\"#{str}\""
    end

    return str
  end

  def shell_join(array)
    array.map { |arg| shell_escape(arg) }.join(' ')
  end

  def run_verbose(*args)
    puts "> #{ cyan(shell_join(args)) }"
    system(*args)
  end

  def puts(*args)
    $stderr.puts *args
  end

  def download(uri, hash=nil)
    require "open-uri"

    filename = File.basename(uri)
    temp_path = File.join(ENV["TMP"] || ENV["TEMP"] || ENV["USERPROFILE"] || "C:/", filename)

    until check_hash(temp_path, hash)
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
    temp_path
  end

  def check_hash(path, hash)
    if !File.exist?(path)
      false
    elsif hash.nil?
      true
    else
      require "digest"

      print "Verify integrity of #{File.basename(path)} ..."
      res = Digest::SHA256.file(path).hexdigest == hash.downcase
      puts(res ? green(" OK") : red(" Failed"))
      res
    end
  end

  def kill_all_msys2_processes
    require "csv"

    puts 'Kill all running msys2 binaries to avoid error "size of shared memory region changed"'
    # See https://github.com/msys2/MSYS2-packages/issues/258
    CSV.parse(`tasklist /M msys-2.0.dll /FO CSV`, headers: true, encoding: 'locale').each do |d|
      puts red(" - killing process: #{d.to_h.inspect}")
      Process.kill(9, d["PID"].to_i)
    end
  end
end
end
end
end
