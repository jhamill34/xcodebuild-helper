require 'coverage_plan'

RSpec.describe XCodeBuildHelper::CoveragePlan do
  context "Setter methods" do
    before(:each) do
      @coverage_plan = XCodeBuildHelper::CoveragePlan.new
    end
    it "should set the report type" do
      @coverage_plan.report_type "REPORT_TYPE"
      expect(@coverage_plan.get_report_type).to eq "REPORT_TYPE"
    end

    it "should set the source files" do
      @coverage_plan.source_files ["path/tofiles/*.m"]
      expect(@coverage_plan.get_source_files).to eq ["path/tofiles/*.m"]
    end
  end
end
