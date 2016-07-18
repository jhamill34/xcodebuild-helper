module XCodeBuildHelper
  class Execute
    def self.call cmd
      begin
        return `#{cmd}`
      rescue
        puts "Error running #{cmd}"
      end
    end
  end
end
