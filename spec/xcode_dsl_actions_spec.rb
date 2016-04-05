require 'xcodebuild-helper'
require 'nokogiri'
require 'fileutils'

RSpec.describe "DSL actions" do
  before(:each) do
    allow(XCodeBuildHelper).to receive(:gem_location).and_return('gem/location')
  end
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
          output "/build/reports"
        end
      end
      allow(FileUtils).to receive(:mkdir_p)
      allow(FileUtils).to receive(:cp)
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
      allow(Dir).to receive(:glob).with('path/to/files/*').and_return(['path/to/files/file.m', 'path/to/files/supporting files/file.h'])
      expect(XCodeBuildHelper::Execute).to receive(:call).with("xcrun llvm-cov show -instr-profile \"/path/to/app/prof\" \"/path/to/app/bin\" path/to/files/file.m path/to/files/supporting\\ files/file.h").and_return("")
      XCodeBuildHelper.generate_coverage(:default, :plan_a)
    end

    context "converting results to html" do
      it "will parse the results and call convert to html" do
        allow(XCodeBuildHelper::Execute).to receive(:call).and_return("/path/to/file/FILE_A\n0 | 1|# some random code\n\nwarning: something went wrong here\n/path/to/file/FILE_B\n0| 2|#other random code")

        mockIndex = double(Nokogiri::HTML::Builder)
        allow(mockIndex).to receive(:to_html).and_return("INDEX STUFF")
        allow(XCodeBuildHelper::CoverageHtmlConverter).to receive(:create_index).and_return(mockIndex)
        allow(File).to receive(:write)

        expect(XCodeBuildHelper::CoverageHtmlConverter).to receive(:convert_file).twice
        XCodeBuildHelper.generate_coverage(:default, :plan_a)
      end

      it "will save the results to a the file name header" do
        mockHtml = double(Nokogiri::HTML::Builder)
        allow(mockHtml).to receive(:to_html).and_return("HTML STUFF")
        converted_result = { :content => mockHtml, :title => "/path/to/file/FILE_A"}

        mockIndex = double(Nokogiri::HTML::Builder)
        allow(mockIndex).to receive(:to_html).and_return("INDEX STUFF")
        allow(XCodeBuildHelper::CoverageHtmlConverter).to receive(:create_index).and_return(mockIndex)
        allow(File).to receive(:write)

        allow(XCodeBuildHelper::Execute).to receive(:call).and_return("warning:something went wrong\nFILE_A:\nHTML STUFF")
        allow(XCodeBuildHelper::CoverageHtmlConverter).to receive(:convert_file).with("FILE_A:\nHTML STUFF").and_return(converted_result)
        expect(File).to receive(:write).with("/build/reports/FILE_A.html", "HTML STUFF")

        XCodeBuildHelper.generate_coverage(:default, :plan_a)
      end

      it "needs to create the output directory first" do
        mockHtml = double(Nokogiri::HTML::Builder)
        allow(mockHtml).to receive(:to_html).and_return("HTML STUFF")
        converted_result = { :content => mockHtml, :title => "/path/to/file/FILE_A"}

        mockIndex = double(Nokogiri::HTML::Builder)
        allow(mockIndex).to receive(:to_html).and_return("INDEX STUFF")
        allow(XCodeBuildHelper::CoverageHtmlConverter).to receive(:create_index).and_return(mockIndex)

        allow(XCodeBuildHelper::Execute).to receive(:call).and_return("FILE_A:\nHTML STUFF")
        allow(XCodeBuildHelper::CoverageHtmlConverter).to receive(:convert_file).and_return(converted_result)
        expect(FileUtils).to receive(:mkdir_p).with('/build/reports')
        allow(File).to receive(:write)

        XCodeBuildHelper.generate_coverage(:default, :plan_a)
      end

      it "will create an index page" do
        mockHtml = double(Nokogiri::HTML::Builder)
        allow(mockHtml).to receive(:to_html).and_return("HTML STUFF")
        converted_result = { :content => mockHtml, :title => "/path/to/file/FILE_A"}

        mockIndex = double(Nokogiri::HTML::Builder)
        allow(mockIndex).to receive(:to_html).and_return("INDEX STUFF")
        allow(XCodeBuildHelper::CoverageHtmlConverter).to receive(:create_index).and_return(mockIndex)

        allow(XCodeBuildHelper::Execute).to receive(:call).and_return("FILE_A:\nHTML STUFF")
        allow(XCodeBuildHelper::CoverageHtmlConverter).to receive(:convert_file).and_return(converted_result)
        allow(File).to receive(:write).with("/build/reports/FILE_A.html", "HTML STUFF")
        expect(File).to receive(:write).with("/build/reports/index.html", "INDEX STUFF")

        XCodeBuildHelper.generate_coverage(:default, :plan_a)
      end

      it "should copy the assets" do
        mockHtml = double(Nokogiri::HTML::Builder)
        allow(mockHtml).to receive(:to_html).and_return("HTML STUFF")
        converted_result = { :content => mockHtml, :title => "/path/to/file/FILE_A"}

        mockIndex = double(Nokogiri::HTML::Builder)
        allow(mockIndex).to receive(:to_html).and_return("INDEX STUFF")
        allow(XCodeBuildHelper::CoverageHtmlConverter).to receive(:create_index).and_return(mockIndex)

        allow(XCodeBuildHelper::Execute).to receive(:call).and_return("FILE_A:\nHTML STUFF")
        allow(XCodeBuildHelper::CoverageHtmlConverter).to receive(:convert_file).and_return(converted_result)
        allow(File).to receive(:write)
        expect(FileUtils).to receive(:cp).with('gem/location/assets/style.css', '/build/reports')

        XCodeBuildHelper.generate_coverage(:default, :plan_a)
      end
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
