require "yaml"

def ridkuse_dirname
  File.expand_path("..", __FILE__)
end

def rubies_filename
  ENV['RIDK_USE_RUBIES'] || File.join(ridkuse_dirname, "rubies.yml")
end

def backslachs(path)
  path.gsub("/", "\\")
end

def forwardslachs(path)
  path.gsub("\\", "/")
end

RUBY_INSTALL_KEY = "SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/"

def find_each_ruby_from_registry
  return to_enum(:find_each_ruby_from_registry) unless block_given?
  
  require "win32/registry"
  begin
    Win32::Registry::HKEY_CURRENT_USER.open(backslachs(RUBY_INSTALL_KEY)) do |reg|
      reg.each_key do |subkey|
        subreg = reg.open(subkey)
        begin
          if subreg['DisplayName'] =~ /^Ruby / && File.directory?(il=subreg['InstallLocation'])
            yield il
          end
        rescue Encoding::InvalidByteSequenceError, Win32::Registry::Error
          # Ignore entries without valid installer data or broken character encoding
        end
      end
    end
  rescue Win32::Registry::Error
  end
end

def find_each_ruby_from_yml
  return to_enum(:find_each_ruby_from_yml) unless block_given?
  YAML.load_file(rubies_filename).each do |rubypath|
    yield rubypath
  end
end

def find_each_ruby(&block)
  return to_enum(:find_each_ruby) unless block_given?
  
  if File.exist?(rubies_filename)
    find_each_ruby_from_yml(&block)
  else
    find_each_ruby_from_registry.sort.each(&block)
  end
end

def each_ruby
  return to_enum(:each_ruby) unless block_given?
  
  find_each_ruby.each_with_index do |rubypath, idx|
    yield(idx + 1, File.expand_path(rubypath))
  end
end
  
def list_rubies
  each_ruby do |idx, rubypath|
    rubyver = begin
      `#{File.join(rubypath, "bin/ruby")} -v`
    rescue => err
      err.to_s
    end
    $stderr.puts "#{idx} - #{rubypath} \t#{rubyver}"
  end
end

def update_rubies
  if File.exist?(rubies_filename)
    rubies = YAML.load_file(rubies_filename)
  else
    rubies = []
  end

  find_each_ruby_from_registry.sort.each do |rubypath|
    rubypath = File.expand_path(rubypath)
    unless rubies.find{|r| File.expand_path(r) == rubypath }
      rubies << rubypath
    end
  end

  $stderr.puts "Update #{rubies_filename}"
  File.write(rubies_filename, YAML.dump(rubies))
end

def in_path_regex(path)
  pathregex = Regexp.escape(forwardslachs(path)).gsub(/\//, "[\\/\\\\\\\\]")
  /(^|;)#{pathregex}[^;]*(;|$)/i
end

def remove_rubies_from_path(vars, rubies)
  if path=vars['PATH']
    rubies.each do |rubypath|
      path = path.gsub(in_path_regex(rubypath)) do |a|
        res = $1.empty? || $2.empty? ? "" : ";"
        $stderr.puts "Disable #{rubypath}"
        res
      end
    end
    vars['PATH'] = path
  end
end

def enable_ruby_in_path(vars, rubypath)
  if (path=vars["PATH"]) && !in_path_regex(rubypath).match(path)
    $stderr.puts "Enable #{rubypath}"
    vars['PATH'] = backslachs(File.join(rubypath, "bin")) + ";" + vars['PATH']
  end
end

def ensure_ridk_use_in_path(vars, rubypath)
  ridkusepath = backslachs(ridkuse_dirname)
  # No need to add ridk_use to PATH if it belongs to current ruby
  ridkusepath = nil if ridkusepath == backslachs(File.join(rubypath, "ridk_use"))

  if ridkusepath && (path=vars['PATH'])
    unless in_path_regex(ridkusepath).match(path)
      path = ridkusepath + ";" + path
    end
    vars['PATH'] = path
  end
  vars['RIDK_USE_PATH'] = ridkusepath
end

def switch_ruby_per_cmd(rubypath, rubies, ps1)
  vars = {
    "PATH" => ENV['PATH'],
    "RIDK_USE_PATH" => nil,
  }
  remove_rubies_from_path(vars, rubies)
  enable_ruby_in_path(vars, rubypath)
  ensure_ridk_use_in_path(vars, rubypath)

  if ps1
    vars.map do |key, val|
      "$env:#{key}=\"#{val.gsub('"', '`"')}\""
    end.join(";")
  else
    vars.map do |key, val|
      "#{key}=#{val}"
    end.join("\n")
  end
end

def select_ruby(rubies, selector)
  ridx = selector.to_i
  if ridx > 0
    rubies = each_ruby.to_h
    selpath = rubies[ridx]
  end
  return selpath if selpath

  if selector =~ /^\/(.*)\/$/
    regex = $1
    _, selpath = rubies.find do |idx, rubypath|
      /#{regex}/i.match(rubypath)
    end
    return selpath
  end
end

def print_help
  $stderr.puts <<-EOT
Usage:
    ridk use [<option>]

Option:
                  Start interactive version selection
    list          Search and list installed ruby versions
    update        Save or update the found ruby versions to rubies.yml
    <number>      Change the active ruby version by index
    /<regex>/     Change the active ruby version by regex
    help          Display this help and exit
EOT
end
      
def run!(args)
  case args[0]
    when "use", "useps1"
      ps1 = args[0] == "useps1"
      case args[1]
        when 'help'
          print_help
        when 'list'
          list_rubies
        when 'update'
          update_rubies
        when String
          rubies = each_ruby.to_h
          rubypath = select_ruby(rubies, args[1])
          unless rubypath
            $stderr.print "Invalid ruby: #{args[1].inspect}"
            exit 1
          end
          puts switch_ruby_per_cmd(rubypath, rubies.values, ps1)
        else
          list_rubies
          rubies = each_ruby.to_h

          loop do
            $stderr.print "Select ruby version to enable: "
            selector = $stdin.gets.strip
            rubypath = select_ruby(rubies, selector)
            next unless rubypath
            puts switch_ruby_per_cmd(rubypath, rubies.values, ps1)
            break
          end
      end
    else
      $stderr.puts "Invalid option #{args[0].inspect}"
  end
end

if $0 == __FILE__
  run!(ARGV)
end
