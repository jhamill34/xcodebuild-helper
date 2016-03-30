module XCodeBuildHelper
  class Execute
    def self.call cmd
      `#{cmd}`
    end
  end
end
