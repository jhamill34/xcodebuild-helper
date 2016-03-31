require 'xcode'
require 'test_plan'
require 'device'

RSpec.describe XCodeBuildHelper::XCode do
  before(:each) do
    @xcode = XCodeBuildHelper::XCode.new
    @xcode.workspace "WORK SPACE"
    @xcode.scheme "SCHEME"
  end

  context "setter methods" do
    it "should have set the workspace attribute" do
      expect(@xcode.get_workspace).to eq "WORK SPACE"
    end

    it "should have set the scheme attribute" do
      expect(@xcode.get_scheme).to eq "SCHEME"
    end
  end

  context "registering a device" do
    before(:each) do
      @device = XCodeBuildHelper::Device.new
      @device.platform "PLATFORM"
    end
    it "should set the device on the project" do
      @xcode.device(:ipad, @device)
      expect(@xcode.get_device(:ipad).get_platform).to eq "PLATFORM"
    end
  end

  context "register a test plan" do
    before(:each) do
      @test_plan = XCodeBuildHelper::TestPlan.new
      @test_plan.report_type "REPORT_TYPE"
    end

    it "should register a test plan on the project" do
      @xcode.test_plan(:plan_a, @test_plan)
      expect(@xcode.get_test_plan(:plan_a).get_report_type).to eq "REPORT_TYPE"
    end
  end

  context "register a code coverage plan" do
    before(:each) do
      @coverage_plan = XCodeBuildHelper::CoveragePlan.new
      @coverage_plan.source_files ["path/to/files/*.m"]
    end

    it "should set the source files" do
      @xcode.coverage_plan(:plan_a, @coverage_plan)
      expect(@xcode.get_coverage_plan(:plan_a).get_source_files).to eq ["path/to/files/*.m"]
    end
  end


  context "register a lint plan" do
    before(:each) do
      @lint_plan = XCodeBuildHelper::LintPlan.new
      @lint_plan.report_type "REPORT_TYPE"
    end

    it "should set the report type" do
      @xcode.lint_plan(:plan_a, @lint_plan)
      expect(@xcode.get_lint_plan(:plan_a).get_report_type).to eq "REPORT_TYPE"
    end
  end
end
