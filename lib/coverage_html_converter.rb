require 'nokogiri'

module XCodeBuildHelper
  LINE_NUMBER_CLASS = "num"
  COVERAGE_CLASS = "coverage"
  SRC_CLASS = "src"
  LINE_BREAK_DELIMITER = "\n"
  LINE_INFO_DELIMITER = "|"

  class CoverageHtmlConverter
    def self.convert_file(input)
      lines = input.split(LINE_BREAK_DELIMITER)
      title = lines.first
      lines = lines[1..-1]
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html {
          doc.head {

          }

          doc.body {
            doc.h1 {
              doc.text title
            }
            doc.table {
              lines.each do |line|
                elements = line.split(LINE_INFO_DELIMITER).map { |l| l.strip }
                doc.tr {
                  doc.td(:class => LINE_NUMBER_CLASS) {
                    doc.text elements[1]
                  }
                  doc.td(:class => SRC_CLASS) {
                    doc.text elements[2]
                  }
                  doc.td(:class => COVERAGE_CLASS) {
                    doc.text elements[0]
                  }
                }
              end
            }
          }
        }
      end

      {:content => builder, :title => title}
    end
  end
end
