require 'test_plan'

RSpec.describe XCodeBuildHelper::TestPlan do
  context "setter methods" do
    it "should set the report type" do
      @test_plan = XCodeBuildHelper::TestPlan.new
      @test_plan.report_type "REPORT_TYPE"
      expect(@test_plan.get_report_type).to eq "REPORT_TYPE"
    end
  end
end
