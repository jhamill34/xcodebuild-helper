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

  def self.build(name, device = nil)
    xcode = @registry[name]

    unless xcode == nil
      cmd = create_base_cmd(xcode)
      if device != nil
        cmd += parse_destination(xcode.get_device(device))
      end
      XCodeBuildHelper::Execute.call(cmd + "clean build | bundle exec xcpretty --color --report json-compilation-database")
    end
  end

  def self.test_suite(name, plan, device = nil)
    xcode = @registry[name]

    unless xcode == nil
      cmd = create_base_cmd(xcode)
      if device != nil
        cmd += parse_destination(xcode.get_device(device))
      end
      XCodeBuildHelper::Execute.call(cmd + "test | bundle exec xcpretty --color --report #{xcode.get_test_plan(plan).get_report_type}")
    end
  end

  def self.create_base_cmd(project)
    "xcodebuild -workspace \"#{project.get_workspace}.xcworkspace\" -scheme #{project.get_scheme} -sdk #{project.get_sdk} -config #{project.get_config} "
  end

  def self.parse_destination(device)
    if device == nil
      ""
    else
      "-destination 'platform=#{device.get_platform},name=#{device.get_name},OS=#{device.get_os}' "
    end
  end

  def self.base_app_location(xcode)
    unless xcode == nil
      cmd = create_base_cmd(xcode)
      result = XCodeBuildHelper::Execute.call(cmd + "-showBuildSettings")
      parse_app_settings(result)
    end
  end

  def self.parse_app_settings(settings)
    result = /OBJROOT = ([a-zA-Z0-9\/ _\-]+)/.match(settings)
    if result != nil
      result[1]
    else
      ""
    end
  end

  def self.app_binary_location(project)
    Dir.glob(base_app_location(project) + "/CodeCoverage/#{project.get_scheme}/Products/#{project.get_config}-#{project.get_sdk}/#{project.get_workspace.gsub(/\s+/, '\\ ')}.app/#{project.get_workspace.gsub(/\s+/,"\\ ")}").first
  end

  def self.profdata_location(project)
    Dir.glob(base_app_location(project) + "/CodeCoverage/#{project.get_scheme}/Coverage.profdata").first
  end

  def self.generate_coverage(name, plan)
    xcode = @registry[name]
    unless xcode == nil
      coverage_plan = xcode.get_coverage_plan(plan)
      result = XCodeBuildHelper::Execute.call("xcrun llvm-cov show -instr-profile \"#{profdata_location(xcode)}\" \"#{app_binary_location(xcode)}\" #{coverage_plan.get_source_files.first}")
    end
  end

  def self.lint(name, plan)
    xcode = @registry[name]
    lint_plan = xcode.get_lint_plan(plan)

    cmd = "bundle exec oclint-json-compilation-database"
    if(lint_plan.get_ignore)
      cmd += " -e \"#{lint_plan.get_ignore}\""
    end
    cmd += " --"
    if(lint_plan.get_report_type && lint_plan.get_output)
      cmd += " -report-type #{lint_plan.get_report_type} -o #{lint_plan.get_output}"
    end

    rules = lint_plan.get_rules
    rules.get_attribute_list.each do |key|
      u_key = rules.send("key_" + key.to_s)
      value = rules.send("get_" + key.to_s)
      cmd += " -rc #{u_key}=#{value}"
    end

    XCodeBuildHelper::Execute.call(cmd)
  end
end
