require 'execute'
require 'device'
require 'test_plan'
require 'coverage_plan'
require 'lint_plan'

module XCodeBuildHelper
  class XCode
    def initialize
      @device_registry = {}
      @tp_registry = {}
      @coverage_registry = {}
      @lint_registry = {}
    end

    def workspace(name)
      @workspace = name
    end

    def get_workspace
      @workspace
    end

    def scheme(name)
      @scheme = name
    end

    def get_scheme
      @scheme
    end

    def device(name, device = nil, &block)
      if device == nil
        if @device_registry[name] == nil
          device = XCodeBuildHelper::Device.new
        else
          device = @device_registry[name]
        end
      end

      if block_given?
        device.instance_eval(&block)
      end

      @device_registry[name] = device
    end

    def get_device(name)
      @device_registry[name]
    end

    def test_plan(name, test_plan = nil, &block)
      if test_plan == nil
        if @tp_registry[name] == nil
          test_plan = XCodeBuildHelper::TestPlan.new
        else
          test_plan = @tp_registry[name]
        end
      end

      if block_given?
        test_plan.instance_eval(&block)
      end

      @tp_registry[name] = test_plan
    end

    def get_test_plan(name)
      @tp_registry[name]
    end

    def coverage_plan(name, coverage_plan = nil, &block)
      if coverage_plan == nil
        if @coverage_registry[name] == nil
          coverage_plan = XCodeBuildHelper::CoveragePlan.new
        else
          coverage_plan = @coverage_registry[name]
        end
      end

      if block_given?
        coverage_plan.instance_eval(&block)
      end

      @coverage_registry[name] = coverage_plan
    end

    def get_coverage_plan(name)
      @coverage_registry[name]
    end

    def lint_plan(name, lint_plan = nil, &block)
      if lint_plan == nil
        if @lint_registry[name] == nil
          lint_plan = XCodeBuildHelper::LintPlan.new
        else
          lint_plan = @lint_registry[name]
        end
      end

      if block_given?
        lint_plan.instance_eval(&block)
      end

      @lint_registry[name] = lint_plan
    end

    def get_lint_plan(name)
      @lint_registry[name]
    end
  end
end
