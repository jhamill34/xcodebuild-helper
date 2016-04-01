require 'xcodebuild-helper'

RSpec.describe "DSL actions" do
  context "build" do
    before(:each) do
      XCodeBuildHelper.define :default do
        workspace "WORK SPACE"
        scheme "SCHEME"
        sdk "SDK"
        config "CONFIG"
        device :ipad do
          platform "PLATFORM"
          name "NAME"
          os "OS"
        end
      end
    end

    it "should create the proper CLI to build the app" do
      expect(XCodeBuildHelper::Execute).to receive(:call).with("xcodebuild -workspace \"WORK SPACE.xcworkspace\" -scheme SCHEME -sdk SDK -config CONFIG clean build | bundle exec xcpretty --color --report json-compilation-database")
      XCodeBuildHelper.build(:default)
    end

    it "should create the proper CLI for the ipad" do
      expect(XCodeBuildHelper::Execute).to receive(:call).with("xcodebuild -workspace \"WORK SPACE.xcworkspace\" -scheme SCHEME -sdk SDK -config CONFIG -destination 'platform=PLATFORM,name=NAME,OS=OS' clean build | bundle exec xcpretty --color --report json-compilation-database")
      XCodeBuildHelper.build(:default, :ipad)
    end
  end

  context "test_suite" do
    before(:each) do
      XCodeBuildHelper.define :default do
        workspace "WORK SPACE"
        scheme "SCHEME"
        sdk "SDK"
        config "CONFIG"

        device :ipad do
          platform "PLATFORM"
          name "NAME"
          os "OS"
        end

        test_plan :plan_a do
          report_type 'html'
        end
      end
    end

    it "should create the proper CLI for testing" do
      expect(XCodeBuildHelper::Execute).to receive(:call).with("xcodebuild -workspace \"WORK SPACE.xcworkspace\" -scheme SCHEME -sdk SDK -config CONFIG test | bundle exec xcpretty --color --report html")
      XCodeBuildHelper.test_suite(:default, :plan_a)
    end

    it "should create the proper CLI for testing for ipad" do
      expect(XCodeBuildHelper::Execute).to receive(:call).with("xcodebuild -workspace \"WORK SPACE.xcworkspace\" -scheme SCHEME -sdk SDK -config CONFIG -destination 'platform=PLATFORM,name=NAME,OS=OS' test | bundle exec xcpretty --color --report html")
      XCodeBuildHelper.test_suite(:default, :plan_a, :ipad)
    end
  end

  context "code coverage" do
    before(:each) do
      XCodeBuildHelper.define :default do
        workspace "WORK SPACE"
        scheme "SCHEME"
        sdk "SDK"
        config "CONFIG"

        device :ipad do
          platform "PLATFORM"
          name "NAME"
          os "OS"
        end

        coverage_plan :plan_a do
          report_type "xml"
          source_files ["path/to/files/*"]
        end
      end
    end

    it "will find the base app directory" do
      expect(XCodeBuildHelper::Execute).to receive(:call).with("xcodebuild -workspace \"WORK SPACE.xcworkspace\" -scheme SCHEME -sdk SDK -config CONFIG -showBuildSettings")
      XCodeBuildHelper.base_app_location(XCodeBuildHelper[:default])
    end

    it "will find the app binary" do
      allow(XCodeBuildHelper).to receive(:base_app_location).and_return("/path/to/app")
      expect(Dir).to receive(:glob).with("/path/to/app/CodeCoverage/SCHEME/Products/CONFIG-SDK/WORK\\ SPACE.app/WORK\\ SPACE").and_return([])
      XCodeBuildHelper.app_binary_location(XCodeBuildHelper[:default])
    end

    it "will find the app profdata" do
      allow(XCodeBuildHelper).to receive(:base_app_location).and_return("/path/to/app")
      expect(Dir).to receive(:glob).with("/path/to/app/CodeCoverage/SCHEME/Coverage.profdata").and_return([])
      XCodeBuildHelper.profdata_location(XCodeBuildHelper[:default])
    end

    it "will return the CLI for finding code coverage" do
      allow(XCodeBuildHelper).to receive(:app_binary_location).and_return("/path/to/app/bin")
      allow(XCodeBuildHelper).to receive(:profdata_location).and_return("/path/to/app/prof")
      expect(XCodeBuildHelper::Execute).to receive(:call).with("xcrun llvm-cov show -instr-profile \"/path/to/app/prof\" \"/path/to/app/bin\" path/to/files/*")
      XCodeBuildHelper.generate_coverage(:default, :plan_a)
    end
  end

  context "lint" do
    before(:each) do
      XCodeBuildHelper.define :default do
        workspace "WORK SPACE"
        scheme "SCHEME"
        sdk "SDK"
        config "CONFIG"

        device :ipad do
          platform "PLATFORM"
          name "NAME"
          os "OS"
        end

        lint_plan :plan_a do
          report_type "REPORT_TYPE"
          output "OUTPUT"
          ignore "IGNORE"
          rules do
            long_line 120
          end
        end
      end
    end
    it "should call the correct CLI for the lint" do
      expect(XCodeBuildHelper::Execute).to receive(:call).with("bundle exec oclint-json-compilation-database -e \"IGNORE\" -- -report-type REPORT_TYPE -o OUTPUT -rc LONG_LINE=120")
      XCodeBuildHelper.lint(:default, :plan_a)
    end
  end
end
