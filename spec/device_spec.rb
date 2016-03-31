require 'device'

RSpec.describe XCodeBuildHelper::Device do
  context "Setter methods" do
    before(:each) do
      @device = XCodeBuildHelper::Device.new
    end

    it "should set the platform name" do
      @device.platform "PLATFORM"
      expect(@device.get_platform).to eq "PLATFORM"
    end

    it "should set the name" do
      @device.name "NAME"
      expect(@device.get_name).to eq "NAME"
    end

    it "should set the name" do
      @device.os "9.2"
      expect(@device.get_os).to eq "9.2"
    end
  end
end
