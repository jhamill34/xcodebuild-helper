require 'xcode'
require 'execute'

module XCodeBuildHelper
  @registry = {}
  def self.[](name)
    @registry[name]
  end

  def self.define(name, &block)
    xcode = @registry[name]
    if xcode == nil
      xcode = XCodeBuildHelper::XCode.new
    end
    xcode.instance_eval(&block)
    @registry[name] = xcode
  end
end

#   def build(opts = {})
#     cmd = create_base_cmd + parse_destination(opts)
#     XCodeBuildHelper::Execute.call(cmd + "clean build | bundle exec xcpretty --color --report json-compilation-database")
#   end
#
#   def test_suite(opts = {})
#     report_type = opts[:report_type] || 'html'
#     cmd = create_base_cmd + parse_destination(opts)
#     XCodeBuildHelper::Execute.call(cmd + "test | bundle exec xcpretty --color --report #{report_type}")
#   end
#
#   def generate_coverage(opts = {})
#     source = opts[:source]
#     report_type = opts[:report_type]
#     result = XCodeBuildHelper::Execute.call("xcrun llvm-cov show -instr-profile \"#{profdata_location}\" \"#{app_binary_location}\" #{source}")
#   end
#
#   def lint(opts = {})
#     cmd = "bundle exec oclint-json-compilation-database"
#     if(opts[:ignore])
#       cmd += " -e \"#{opts[:ignore]}\""
#     end
#     cmd += " --"
#     if(opts[:report_type] && opts[:output])
#       cmd += " -report-type #{opts[:report_type]} -o #{opts[:output]}"
#     end
#
#     if opts[:custom_rules]
#       opts[:custom_rules].each do |key, value|
#         cmd += " -rc #{key}=#{value}"
#       end
#     end
#
#     XCodeBuildHelper::Execute.call(cmd)
#   end
#
#   def base_app_location
#     cmd = create_base_cmd
#     result = XCodeBuildHelper::Execute.call(cmd + "-showBuildSettings")
#     parse_app_settings(result)
#   end
#
#   def app_binary_location
#     Dir.glob(base_app_location + "/CodeCoverage/#{@attributes[:scheme]}/Products/Debug-iphonesimulator/#{@attributes[:workspace].gsub(/\s+/, '\\ ')}.app/#{@attributes[:workspace].gsub(/\s+/,"\\ ")}").first
#   end
#
#   def profdata_location
#     Dir.glob(base_app_location + "/CodeCoverage/#{@attributes[:scheme]}/Coverage.profdata").first
#   end
#
#   def parse_app_settings(settings)
#     result = /OBJROOT = ([a-zA-Z0-9\/ _\-]+)/.match(settings)
#     if result != nil
#       result[1]
#     else
#       ""
#     end
#   end
#
#   def create_base_cmd
#     "xcodebuild -workspace \"#{@attributes[:workspace]}.xcworkspace\" -scheme #{@scheme} -sdk iphonesimulator -config Debug "
#   end
#
#   def parse_destination(opts = {})
#     if opts[:platform] && opts[:name] && opts[:os]
#       "-destination 'platform=#{opts[:platform]},name=#{opts[:name]},OS=#{opts[:os]}' "
#     else
#       ""
#     end
#   end
#   private :create_base_cmd, :parse_destination, :parse_app_settings
