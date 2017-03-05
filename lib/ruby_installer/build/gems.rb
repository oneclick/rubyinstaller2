require "yaml"

module RubyInstaller
module Build # Use for: Build, Runtime
  module Gems
    class InstallSpec
      attr_accessor :gem_name
      attr_accessor :gem_version
      attr_accessor :gem_build

      attr_accessor :gem_cmd
      attr_accessor :gem_install_opts

      def initialize(gem_name)
        @gem_name = gem_name.dup
        @gem_cmd = "gem"
        @gem_install_opts = []

        fname = File.expand_path("../gems/#{gem_name}.yaml", __FILE__)
        if File.exist?(fname)
          yaml = YAML.load_file(fname)
          raise ArgumentError, "Not a Hash in #{fname}" unless yaml.is_a?(Hash)

          yaml.each do |key, value|
            send("#{key}=", value)
          end
        end
      end

      def install
        if gem_build
          out = run_capture_output(gem_cmd, "build", gem_build)
          if out =~ /File: (.*)/
            gem_file = $1
          else
            raise "Failed to build #{gem_name}"
          end
        end

        if gem_version
          version_opts = ["--version", gem_version]
        end

        run(gem_cmd, "install", *gem_install_opts, gem_file || gem_name, *version_opts)
      end

      def run(*args)
        puts args.join(" ")
        res = system(*args)
        raise "Command failed: #{args.join(" ")}" unless res
      end

      def run_capture_output(*args)
        puts args.join(" ")
        IO.popen(args, &:read)
      end
    end

    def self.install(*gems, **options)
      gems.each do |name|
        spec = InstallSpec.new(name)
        options.each do |key, value|
          spec.send("#{key}=", value)
        end
        spec.install
      end
    end
  end
end
end
