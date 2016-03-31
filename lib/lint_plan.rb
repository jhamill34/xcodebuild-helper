require 'rules'

module XCodeBuildHelper
  class LintPlan
    def report_type(name)
      @report_type = name
    end
    def get_report_type
      @report_type
    end

    def output(name)
      @output = name
    end
    def get_output
      @output
    end

    def ignore(name)
      @ignore = name
    end
    def get_ignore
      @ignore
    end

    def rules(rule = nil, &block)
      if block_given?
        if @rules == nil
          rule = XCodeBuildHelper::Rules.new
        else
          rule = @rules
        end
        rule.instance_eval(&block)
      end
      @rules = rule
    end
    def get_rules
      @rules
    end
  end
end
