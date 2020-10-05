require "fiddle"

module RubyInstaller
module Build # Use for: Build, Runtime
  # :nodoc:
  class OsProcess
    class Error < RuntimeError
    end
    class WinApiError < Error
    end

    KERNEL32 = Fiddle.dlopen('kernel32.dll')
    PSAPI = Fiddle.dlopen('Psapi.dll')
    EnumProcesses = Fiddle::Function.new(
        PSAPI['EnumProcesses'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT
    )
    OpenProcess = Fiddle::Function.new(
        KERNEL32['OpenProcess'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_VOIDP
    )
    EnumProcessModulesEx = Fiddle::Function.new(
        PSAPI['EnumProcessModulesEx'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT
    )
    GetModuleFileNameEx = Fiddle::Function.new(
        PSAPI['GetModuleFileNameExW'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT
    )
    GetProcessImageFileName = Fiddle::Function.new(
        PSAPI['GetProcessImageFileNameW'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT
    )
    CloseHandle = Fiddle::Function.new(
        KERNEL32['CloseHandle'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT
    )

    attr_reader :pid

    def initialize(pid:)
      @pid = pid
      @hProcess = nil
    end

    def open(perm: 0x0400 | #PROCESS_QUERY_INFORMATION
                   0x0010 ) # PROCESS_VM_READ)
      # Get a handle to the process.
      hProcess ||= OpenProcess.call( perm, 0, @pid )

      raise WinApiError, "Error in OpenProcess pid: #{@pid.inspect}" if hProcess.null?

      begin
        yield hProcess
      ensure
        # Release the handle to the process.
        CloseHandle.call( hProcess )
      end
    end

    def image_name
      open(perm: 0x1000 # PROCESS_QUERY_LIMITED_INFORMATION
           ) do |hProcess|
        szName = Fiddle::Pointer.malloc(1024 * 2, Fiddle::RUBY_FREE)
        szNameLen = GetProcessImageFileName.call(hProcess, szName, szName.size)

        # return the module name and handle value.
        szName[0, szNameLen * 2].encode(Encoding::UTF_8, Encoding::UTF_16LE)
      end
    end

    def each_module
      return enum_for(:each_module) unless block_given?

      # Get a list of all the modules in this process.
      hMods = Fiddle::Pointer.malloc(1024 * Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE)
      cbNeeded = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT, Fiddle::RUBY_FREE)

      open do |hProcess|
        if EnumProcessModulesEx.call(hProcess, hMods, hMods.size, cbNeeded, 3) == 0
          raise WinApiError, "Error in EnumProcessModulesEx"
        else
          szModName = Fiddle::Pointer.malloc(1024 * 2, Fiddle::RUBY_FREE)
          needed = cbNeeded[0, Fiddle::SIZEOF_INT].unpack("L")[0] / Fiddle::SIZEOF_VOIDP
          needed.times do |i|
            # Get the full path to the module's file.
            hMod = (hMods + i*Fiddle::SIZEOF_VOIDP).ptr
            szModNameLen = GetModuleFileNameEx.call( hProcess, hMod, szModName,
                                      szModName.size / 2)
            if szModNameLen != 0
              # Yield the module name and handle value.
              name = szModName[0, szModNameLen * 2].encode(Encoding::UTF_8, Encoding::UTF_16LE)
              yield hMod.to_i, name
            end
          end
        end
      end
    end

    def self.each_process
      return enum_for(:each_process) unless block_given?

      aProcesses = Fiddle::Pointer.malloc(1024 * Fiddle::SIZEOF_INT, Fiddle::RUBY_FREE)
      cbNeeded = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT, Fiddle::RUBY_FREE)

      # Get the list of process identifiers.
      if EnumProcesses.call( aProcesses, aProcesses.size, cbNeeded ) == 0
        raise WinApiError, "Error in EnumProcesses"
      else
        # Calculate how many process identifiers were returned.
        cProcesses = cbNeeded[0, Fiddle::SIZEOF_INT].unpack("L")[0] / Fiddle::SIZEOF_INT

        # Yield the names of the modules for each process.
        cProcesses.times do |i|
          pid = aProcesses[i*Fiddle::SIZEOF_INT, Fiddle::SIZEOF_INT].unpack("L")[0]
          yield self.new(pid: pid)
        end
      end
    end

    def self.each_process_with_dll(dll_name)
      return enum_for(:each_process_with_dll, dll_name) unless block_given?

      each_process do |proc|
        begin
          if proc.each_module.find { |_hMod, mod| File.basename(mod) == dll_name }
            yield proc
          end
        rescue WinApiError
          # ignore processes without query permission
        end
      end
    end
  end
end
end
