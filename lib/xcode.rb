require 'execute'

module XCodeBuildHelper
  class XCode
    attr_reader :workspace, :scheme

    def initialize(workspace = "", scheme = "")
      @workspace = workspace
      @scheme = scheme
    end

    def build(opts = {})
      cmd = create_base_cmd + parse_destination(opts)
      XCodeBuildHelper::Execute.call(cmd + "build")
    end

    def test_suite(opts = {})
      cmd = create_base_cmd + parse_destination(opts)
      XCodeBuildHelper::Execute.call(cmd + "test")
    end

    def generate_coverage(source = "")
      XCodeBuildHelper::Execute.call("xcrun llvm-cov show -instr-profile \"#{profdata_location}\" \"#{app_binary_location}\" \"#{source}\"")
    end

    def base_app_location
      cmd = create_base_cmd
      result = XCodeBuildHelper::Execute.call(cmd + "-showBuildSettings")
      parse_app_settings(result)
    end

    def app_binary_location
      Dir.glob(base_app_location + "/CodeCoverage/#{@scheme}/Products/Debug-iphonesimulator/#{@workspace.gsub(/\s+/, '\\ ')}.app/#{@workspace.gsub(/\s+/,"\\ ")}").first
    end

    def profdata_location
      Dir.glob(base_app_location + "/CodeCoverage/#{@scheme}/Coverage.profdata")
    end

    def parse_app_settings(settings)
      result = /OBJROOT = ([a-zA-Z0-9\/]+)/.match(settings)
      if result != nil
        result[1]
      else
        ""
      end
    end

    def create_base_cmd
      "xcodebuild -workspace \"#{@workspace}.xcworkspace\" -scheme #{@scheme} -sdk iphonesimulator -config Debug "
    end

    def parse_destination(opts = {})
      if opts[:platform] && opts[:name] && opts[:os]
        "-destination 'platform=#{opts[:platform]},name=#{opts[:name]},OS=#{opts[:os]}' "
      else
        ""
      end
    end
    private :create_base_cmd, :parse_destination, :parse_app_settings
  end
end
