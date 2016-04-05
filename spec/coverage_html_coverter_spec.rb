require 'coverage_html_converter'
require 'nokogiri'

RSpec.describe XCodeBuildHelper::CoverageHtmlConverter do
  context "#convert_file" do
    it "should return a table element" do
      input = "TITLE:\n1 | 12|# some random code\n0 | 13|# other random code"
      output = XCodeBuildHelper::CoverageHtmlConverter.convert_file input
      document = Nokogiri::HTML(output[:content].to_html)

      expect(output[:title]).to eq "TITLE"
      expect(output[:coverage]).to eq 0.5
      # assert the look of the document
      expect(document.xpath('//html/head/link[@href]').first[:href]).to eq 'style.css'
      expect(document.css('body h1').first.to_html).to eq "<h1>TITLE</h1>"
      expect(document.css('body div.total_coverage').first.to_html).to eq "<div class=\"total_coverage low\">50.0%</div>"
      expect(document.css('body table tr').length).to eq 2
      expect(document.css('body table tr').first.to_html.gsub("\n", "")).to eq "<tr class=\"covered\"><td class=\"num\">12</td><td class=\"src\"><pre><code># some random code</code></pre></td><td class=\"coverage\">1x</td></tr>"
    end

    it "should handle rows without coverage" do
      input = "TITLE\n | 12|# some random code\n 1| 13|# other random code"
      output = XCodeBuildHelper::CoverageHtmlConverter.convert_file input
      document = Nokogiri::HTML(output[:content].to_html)

      # assert the look of the document
      expect(output[:coverage]).to eq 1.0
      expect(document.css('body table tr').first.to_html.gsub("\n", "")).to eq "<tr class=\"irrelevant\"><td class=\"num\">12</td><td class=\"src\"><pre><code># some random code</code></pre></td><td class=\"coverage\"></td></tr>"
    end

    it "should handle rows without coverage" do
      input = "TITLE\n 0| 12|# some random code\n 0| 13|# other random code"
      output = XCodeBuildHelper::CoverageHtmlConverter.convert_file input
      document = Nokogiri::HTML(output[:content].to_html)

      # assert the look of the document
      expect(output[:coverage]).to eq 0.0
      expect(document.css('body table tr').first.to_html.gsub("\n", "")).to eq "<tr class=\"uncovered\"><td class=\"num\">12</td><td class=\"src\"><pre><code># some random code</code></pre></td><td class=\"coverage\">!</td></tr>"
    end
  end

  context "#create_index" do
    it "should create a table of all the files" do
      input = [{:content => double(Nokogiri::HTML::Builder), :title => 'FILE_A', :coverage => 1.0}, {:content => double(Nokogiri::HTML::Builder), :title => 'FILE_B', :coverage => 0.5}]

      output = XCodeBuildHelper::CoverageHtmlConverter.create_index input
      document = Nokogiri::HTML(output.to_html)
      expect(document.xpath('//html/head/link[@href]').first[:href]).to eq 'style.css'
      expect(document.css('body h1').first.to_html).to eq "<h1>Code Coverage</h1>"
      expect(document.css('body div.total_coverage').first.to_html).to eq "<div class=\"total_coverage mid\">75.0%</div>"
      expect(document.css('body table.main tr').length).to eq 2
      expect(document.css('body table.main tr').first.to_html.gsub("\n", "")).to eq "<tr class=\"file\"><td class=\"name\"><a href=\"FILE_A.html\">FILE_A</a></td><td class=\"coverage high\">100.0%</td></tr>"
    end
  end
end
