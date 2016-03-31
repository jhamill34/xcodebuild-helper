require 'lint_plan'
require 'rules'

RSpec.describe XCodeBuildHelper::LintPlan do
  before(:each) do
    @lint_plan = XCodeBuildHelper::LintPlan.new
  end

  context "Setter methods" do
    it "should set the report type" do
      @lint_plan.report_type "REPORT_TYPE"
      expect(@lint_plan.get_report_type).to eq "REPORT_TYPE"
    end
    it "should set the output type" do
      @lint_plan.output "OUTPUT_LOCATION"
      expect(@lint_plan.get_output).to eq "OUTPUT_LOCATION"
    end
    it "should set the ignore type" do
      @lint_plan.ignore "IGNORE"
      expect(@lint_plan.get_ignore).to eq "IGNORE"
    end
    context "setting rules" do
      before(:each) do
        @rules = XCodeBuildHelper::Rules.new
        @rules.long_line 120
        @rules.short_variable_name 3
      end
      it "should set the rule list" do
        @lint_plan.rules @rules
        expect(@lint_plan.get_rules.get_long_line).to eq 120
        expect(@lint_plan.get_rules.get_short_variable_name).to eq 3 
      end
    end
  end
end
