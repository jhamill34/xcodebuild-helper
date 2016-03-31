# This is what I'm shooting for:
# XCodeBuildHelper.define :default do
#   workspace "Service Logistics"
#   scheme "ServiceLogistics"
#
#   device :ipad2 do
#       platform 'iOS Simulator'
#       name 'iPad 2'
#       os '9.2'
#   end
#
#   test_suite do
#     report 'junit'
#   end
#
#   coverage do
#     report 'xml'
#     source 'DSL462_iOS/**/*.m'
#   end
#
#   lint do
#     report 'pmd'
#     output 'build/reports/lint.xml'
#     ignore 'Pods'
#     rules  {
#       'LONG_LINE' => 120
#     }
#   end
# end
require 'xcodebuild-helper'


RSpec.describe "DSL" do
  context ".define" do
    it "should register a default setting" do
      # Given
      XCodeBuildHelper.define :default do |x|
        x.workspace = "WORK SPACE"
        x.scheme = "SCHEME"
      end
      expect(XCodeBuildHelper::Execute).to receive(:call).with("xcodebuild -workspace \"WORK SPACE.xcworkspace\" -scheme SCHEME -sdk iphonesimulator -config Debug clean build | bundle exec xcpretty --color --report json-compilation-database")
      XCodeBuildHelper.build
    end
  end
end
