require 'xcodebuild-helper'

RSpec.describe "DSL" do
  context "define" do
    before(:each) do
      XCodeBuildHelper.define :default do
        workspace "WORK SPACE"
        scheme "SCHEME"
      end
    end

    it "should register the default with a workspace" do
      expect(XCodeBuildHelper[:default].get_workspace).to eq("WORK SPACE")
    end

    it "should register the default with a scheme" do
      expect(XCodeBuildHelper[:default].get_scheme).to eq("SCHEME")
    end
  end

  context "registering a device" do
    before(:each) do
      XCodeBuildHelper.define :default do
        workspace "WORK SPACE"
        scheme "SCHEME"
        device :ipad do
          platform "PLATFORM"
          name "NAME"
          os "9.2"
        end

        device :iphone do
          platform "PLATFORM_2"
          name "NAME_2"
          os "7.0"
        end
      end
    end
    it "should register an ipad on the project" do
      expect(XCodeBuildHelper[:default].get_device(:ipad).get_platform).to eq "PLATFORM"
    end

    it "should register an iphone on the project" do
      expect(XCodeBuildHelper[:default].get_device(:iphone).get_os).to eq "7.0"
    end

    it "should not overwrite the device" do
      XCodeBuildHelper.define :default do
        device :ipad do
          name "IPAD"
        end
      end
      expect(XCodeBuildHelper[:default].get_device(:ipad).get_platform).to eq "PLATFORM"
      expect(XCodeBuildHelper[:default].get_device(:ipad).get_name).to eq "IPAD"
    end
  end

  context "register a test plan" do
    before(:each) do
      XCodeBuildHelper.define :default do
        workspace "WORK SPACE"
        scheme "SCHEME"
        test_plan :plan_a do
          report_type 'junit'
        end
      end
    end

    it "should register a test plan a on the project" do
      report_type = XCodeBuildHelper[:default].get_test_plan(:plan_a).get_report_type
      expect(report_type).to eq 'junit'
    end

    it "should not overwrite the test plan" do
      XCodeBuildHelper.define :default do
        test_plan :plan_a do
        end
      end

      report_type = XCodeBuildHelper[:default].get_test_plan(:plan_a).get_report_type
      expect(report_type).to eq 'junit'
    end
  end

  context "register a coverage plan" do
    before(:each) do
      XCodeBuildHelper.define :default do
        workspace "WORK SPACE"
        scheme "SCHEME"
        coverage_plan :plan_a do
          source_files ['/path/to/files/*.m']
          report_type "REPORT_TYPE"
        end
      end
    end
    it "should set the source files" do
      expect(XCodeBuildHelper[:default].get_coverage_plan(:plan_a).get_source_files).to eq ['/path/to/files/*.m']
    end

    it "should not overwrite the coverage plan" do
      XCodeBuildHelper.define :default do
        coverage_plan :plan_a do
          report_type "EXPECTED"
        end
      end

      expect(XCodeBuildHelper[:default].get_coverage_plan(:plan_a).get_report_type).to eq "EXPECTED"
      expect(XCodeBuildHelper[:default].get_coverage_plan(:plan_a).get_source_files).to eq ['/path/to/files/*.m']
    end
  end

  context "register a lint plan" do
    before(:each) do
      XCodeBuildHelper.define :default do
        workspace "WORK SPACE"
        lint_plan :plan_a do
          report_type "REPORT_TYPE"
          output "OUTPUT"
          ignore "IGNORE"
          rules do
            long_line 120
            short_variable_name 3
          end
        end
      end

    end

    it "should set the lint plan" do
      expect(XCodeBuildHelper[:default].get_lint_plan(:plan_a).get_report_type).to eq "REPORT_TYPE"
    end

    it "should set the rules" do
      expect(XCodeBuildHelper[:default].get_lint_plan(:plan_a).get_rules.get_long_line).to eq 120
    end

    it "should not overwrite the lint_plan" do
      XCodeBuildHelper.define :default do
        lint_plan :plan_a do
          report_type "EXPECTED"
        end
      end

      expect(XCodeBuildHelper[:default].get_lint_plan(:plan_a).get_report_type).to eq "EXPECTED"
      expect(XCodeBuildHelper[:default].get_lint_plan(:plan_a).get_output).to eq "OUTPUT"
    end

    it "should not overwrite previous rules" do
      XCodeBuildHelper.define :default do
        lint_plan :plan_a do
          rules do
            long_line 100
          end
        end
      end

      expect(XCodeBuildHelper[:default].get_lint_plan(:plan_a).get_rules.get_long_line).to eq 100
      expect(XCodeBuildHelper[:default].get_lint_plan(:plan_a).get_rules.get_short_variable_name).to eq 3
    end
  end

  context "edit an existing build plan" do
    it "should overwrite the workspace but not the scheme" do
      XCodeBuildHelper.define :default do
        workspace "WORK SPACE"
        scheme "SCHEME"
      end

      XCodeBuildHelper.define :default do
        workspace "EXPECTED"
      end
      expect(XCodeBuildHelper[:default].get_workspace).to eq "EXPECTED"
      expect(XCodeBuildHelper[:default].get_scheme).to eq "SCHEME"
    end
  end
end
