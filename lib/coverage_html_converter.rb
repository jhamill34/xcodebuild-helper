require 'nokogiri'

module XCodeBuildHelper
  LINE_NUMBER_CLASS = "num"
  COVERAGE_CLASS = "coverage"
  SRC_CLASS = "src"
  LINE_BREAK_DELIMITER = "\n"
  LINE_INFO_DELIMITER = "|"

  class CoverageHtmlConverter
    def self.preprocess_file(lines)
      relevent_lines = 0.0
      covered_lines = 0.0
      lines.each do |line|
        elements = line.split(LINE_INFO_DELIMITER).map { |l| l.strip }
        if elements[0] != ""
          relevent_lines += 1.0
          covered_lines += 1.0 if elements[0].to_f > 0.0
        end
      end

      covered_lines / relevent_lines
    end

    def self.convert_file(input)
      lines = input.split(LINE_BREAK_DELIMITER)
      title = lines.first
      lines = lines[1..-1]

      total_coverage = preprocess_file(lines)
      coverage_string = (total_coverage * 100).to_s + "%"
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html {
          doc.head {

          }

          doc.body {
            doc.h1 {
              doc.text title
            }
            doc.div(:class => "total_coverage"){
              doc.text coverage_string
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

      {:content => builder, :title => title, :coverage => total_coverage}
    end
  end
end
