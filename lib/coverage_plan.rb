module XCodeBuildHelper
  class CoveragePlan
    def report_type(name)
      @report_type = name
    end

    def get_report_type
      @report_type
    end

    def source_files(name)
      @source_files = name
    end

    def get_source_files
      @source_files
    end
  end
end
