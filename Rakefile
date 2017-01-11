$: << File.expand_path("../lib", __FILE__)

require "build_utils"
require "ruby_package"
Dir['*/task.rake'].each{|f| load(f) }

task :devkit do
  require "devkit"
end

rubies = Dir["compile/ruby-*"]

ENV['RI_ARCHS'] ||= 'x64'
ENV['RI_ARCHS'].split(":").each do |arch|

  rubies.each do |compiledir|
    pack = RubyPackage.new( compiledir: compiledir, arch: arch, rootdir: __dir__ ).freeze

    namespace pack.rake_namespace do

      compile = CompileTask.new( package: pack ).freeze
      sandbox = SandboxTask.new( package: pack, compile_task: compile ).freeze
      InstallerTask.new( package: pack, sandbox_task: sandbox ).freeze
    end
  end
end
