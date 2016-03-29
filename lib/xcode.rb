require 'execute'

class XCode
  attr_reader :workspace, :scheme

  def initialize(workspace = "", scheme = "")
    @workspace = workspace
    @scheme = scheme
  end

  def build(opts = {})
    cmd = create_base_cmd + parse_destination(opts)
    Execute.call(cmd + "build")
  end

  def test_suite(opts = {})
    cmd = create_base_cmd + parse_destination(opts)
    Execute.call(cmd + "test")
  end

  def base_app_location
    cmd = create_base_cmd
    result = Execute.call(cmd + "-showBuildSettings")
    parse_app_settings(result)
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
    "xcodebuild -workspace #{@workspace} -scheme #{@scheme} -config Debug "
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
