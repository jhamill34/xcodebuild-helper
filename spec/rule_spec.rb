require 'rules'

RSpec.describe XCodeBuildHelper::Rules do
  before(:each) do
    @rules = XCodeBuildHelper::Rules.new
  end
  context "Setter methods" do
    it "should set the long line rule" do
      @rules.long_line 120
      expect(@rules.get_long_line).to eq 120
    end

    it "should set the shor variable name rule" do
      @rules.short_variable_name 3
      expect(@rules.get_short_variable_name).to eq 3
    end
  end

  context "key methods" do
    it "should return the uppercase version of the method" do
      @rules.long_line 120
      expect(@rules.key_long_line).to eq "LONG_LINE"
    end

    it "should return the uppercase version of the method" do
      expect(@rules.key_long_line).to eq nil
    end
  end

  context "get list of attributes" do
    it "should return a list of attributes" do
      @rules.long_line 120
      @rules.short_variable_name 3
      expect(@rules.get_attribute_list).to eq [:long_line, :short_variable_name]
    end
  end
end
