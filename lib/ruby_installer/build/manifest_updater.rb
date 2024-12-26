module RubyInstaller
  module Build
    class ManifestUpdater
      def self.update_file(from_fname, manifest_xml_string, to_fname)
        image = File.binread(from_fname)
        update_blob(image, manifest_xml_string, filename: from_fname)
        File.binwrite(to_fname, image)
      end

      def self.update_blob(dll_or_exe_data, manifest_xml_string, filename: nil)
        # There are two regular options to add a custom manifest:
        # 1. Change a given exe file per Microsofts "mt.exe" after the build
        # 2. Specify a the manifest while linking with the MINGW toolchain
        #
        # Since we don't want to depend on particular Microsoft tools and want to avoid additional patching of the ruby build, we do a nifty trick here.
        # We patch the exe file manually.
        # Removing unnecessary spaces and comments from the embedded XML manifest gives us enough space to add the above XML elements.
        # Then the default MINGW manifest gets replaced by our custom XML content.
        # The rest of the available bytes is simply padded with spaces, so that we don't change positions within the EXE image.
        success = false
        dll_or_exe_data.gsub!(/<\?xml.*?<assembly.*?<\/assembly>\n/m) do |m|
          success = true
          newm = m.gsub(/^\s*<\/assembly>\s*$/, manifest_xml_string + "</assembly>")
            .gsub(/<!--.*?-->/m, "")
            .gsub(/^ +/, "")
            .gsub(/\n+/m, "\n")

          raise "replacement manifest too big #{m.bytesize} < #{newm.bytesize}" if m.bytesize < newm.bytesize
          newm + " " * (m.bytesize - newm.bytesize)
        end
        raise "no manifest found#{ "in #{filename}" if filename}" unless success
      end
    end
  end
end
