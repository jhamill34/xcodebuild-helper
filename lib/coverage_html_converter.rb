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

    def self.threshold_class(value)
        if value > 0.85
          "high"
        elsif value > 0.7
          "mid"
        else
          "low"
        end
    end

    def self.create_index(file_list)
      total_coverage = 0.0
      total = 0
      file_list.each do |file|
        total_coverage += file[:coverage]
        total += 1.0
      end
      average_coverage = total_coverage / total

      Nokogiri::HTML::Builder.new do |doc|
        doc.html{
          doc.head{
            doc.link(:href => 'style.css', :media => "all", :rel => "stylesheet")
          }
          doc.body{
            doc.h1{
              doc.text "Code Coverage"
            }

            doc.div(:class => "total_coverage #{threshold_class(average_coverage)}"){
              doc.text (average_coverage * 100).round(2).to_s + '%'
            }

            doc.table(:class => "main"){
              file_list.each do |file|
                doc.tr(:class => 'file'){
                  doc.td(:class => 'name'){
                    doc.a(:href => (file[:title] + '.html')){
                      doc.text file[:title]
                    }
                  }
                  doc.td(:class => "coverage #{threshold_class(file[:coverage])}"){
                    doc.text (file[:coverage] * 100).round(2).to_s + "%"
                  }
                }
              end
            }
          }
        }
      end
    end

    def self.convert_file(input)
      lines = input.split(LINE_BREAK_DELIMITER)
      title = File.basename(lines.first.gsub(/:$/, ''))
      lines = lines[1..-1]

      total_coverage = preprocess_file(lines)
      coverage_string = (total_coverage * 100).round(2).to_s + "%"
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html {
          doc.head {
            doc.link(:href => 'style.css', :media => "all", :rel => "stylesheet")
          }

          doc.body {
            doc.h1 {
              doc.text title
            }
            doc.div(:class => "total_coverage #{threshold_class(total_coverage)}"){
              doc.text coverage_string
            }
            doc.table {
              lines.each do |line|
                elements = line.split(LINE_INFO_DELIMITER)
                if elements[0].strip == ""
                  additional_class = "irrelevant"
                elsif elements[0].to_f > 0.0
                  additional_class = "covered"
                else
                  additional_class = "uncovered"
                end
                doc.tr(:class => additional_class) {
                  doc.td(:class => LINE_NUMBER_CLASS) {
                    if elements[1]
                      doc.text elements[1].strip
                    end
                  }
                  doc.td(:class => SRC_CLASS) {
                    doc.pre {
                      doc.code {
                        doc.text elements[2]
                      }
                    }
                  }


                  doc.td(:class => COVERAGE_CLASS) {
                    if elements[0] && elements[0].strip != ""
                      if elements[0].to_f > 0.0
                        doc.text elements[0].strip + "x"
                      else
                        doc.text "!"
                      end
                    end
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
