require 'coverage_html_converter'

RSpec.describe XCodeBuildHelper::CoverageHtmlConverter do
  context "#convert" do
    it "should convert simple text to html" do
      converter = XCodeBuildHelper::CoverageHtmlConverter.new
      input = "0|  12|# some random code written here"
      output = converter.convert input
      expect(output).to eq "<tr><td class=\"num\">12</td><td class=\"src\"># some random code written here</td><td class=\"coverage\">0</td></tr>"
    end
  end
end
