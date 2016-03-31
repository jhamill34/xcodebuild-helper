module XCodeBuildHelper
  class TestPlan
    def report_type(name)
      @report_type = name
    end

    def get_report_type
      @report_type
    end
  end
end
