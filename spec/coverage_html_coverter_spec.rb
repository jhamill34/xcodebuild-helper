require 'coverage_html_converter'
require 'nokogiri'

RSpec.describe XCodeBuildHelper::CoverageHtmlConverter do
  context "#convert_file" do
    it "should return a table element" do
      input = "TITLE\n0 | 12|# some random code\n1 | 13|# other random code"
      output = XCodeBuildHelper::CoverageHtmlConverter.convert_file input
      document = Nokogiri::HTML(output[:content].to_html)

      expect(output[:title]).to eq "TITLE"
      # assert the look of the document
      expect(document.css('body h1').first.to_html).to eq "<h1>TITLE</h1>"
      expect(document.css('body table tr').length).to eq 2
      expect(document.css('body table tr').first.to_html.gsub("\n", "")).to eq "<tr><td class=\"num\">12</td><td class=\"src\"># some random code</td><td class=\"coverage\">0</td></tr>"
    end
  end
end
