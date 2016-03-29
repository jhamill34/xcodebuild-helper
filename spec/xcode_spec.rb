require 'xcode'

RSpec.describe XCode do
  before(:each) do
    @xcode = XCode.new "WORK_SPACE", "SCHEME"
  end

  context "Initializer" do
    it "sets workspace in the constructor" do
      expect(@xcode.workspace).to eq "WORK_SPACE"
    end

    it "sets scheme in the constructor" do
      expect(@xcode.scheme).to eq "SCHEME"
    end
  end

  context "#build" do
    it "will call xcodebuild with proper parameters" do
      expect(Execute).to receive(:call).with("xcodebuild -workspace WORK_SPACE -scheme SCHEME -config Debug build")
      @xcode.build
    end

    it "will call with optional destination parameters" do
      expect(Execute).to receive(:call).with("xcodebuild -workspace WORK_SPACE -scheme SCHEME -config Debug -destination 'platform=PLATFORM,name=NAME,OS=myOS' build")
      @xcode.build :platform => 'PLATFORM', :name => 'NAME', :os => 'myOS'
    end
  end

  context "#test_suite" do
    it "will call the correct text configuration" do
      expect(Execute).to receive(:call).with("xcodebuild -workspace WORK_SPACE -scheme SCHEME -config Debug test")
      @xcode.test_suite
    end

    it "will call with optional destination parameters" do
      expect(Execute).to receive(:call).with("xcodebuild -workspace WORK_SPACE -scheme SCHEME -config Debug -destination 'platform=PLATFORM,name=NAME,OS=myOS' test")
      @xcode.test_suite :platform => 'PLATFORM', :name => 'NAME', :os => 'myOS'
    end
  end

  context "#base_app_location" do
    it "will get the app options" do
      expect(Execute).to receive(:call).with("xcodebuild -workspace WORK_SPACE -scheme SCHEME -config Debug -showBuildSettings")
      @xcode.base_app_location
    end

    it "will return the path" do
      allow(Execute).to receive(:call).and_return("OPTION_A = something \nOBJROOT = /path/to/app\nOPTION_B = something else")
      expect(@xcode.base_app_location).to eq '/path/to/app'
    end
  end

	# coverage_directory = Dir[File.join(app_directory.strip, '/CodeCoverage/ServiceLogistics')].first
	# puts `xcrun llvm-cov show -instr-profile #{coverage_directory}/Coverage.profdata "#{coverage_directory}/Products/Debug-iphonesimulator/Service Logistics.app/Service Logistics" DSL462_iOS/**/*.m`
  context "#app_binary_location" do
    xit "will return the location of the app executable" do

    end
  end

  context "#profdata_location" do
    xit "will return the location of the profdata" do

    end
  end
end
