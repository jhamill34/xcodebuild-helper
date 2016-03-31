module XCodeBuildHelper
  class Rules
    def initialize
      @attributes = {}
    end

    def method_missing(name, *args, &block)
      if name.to_s.start_with? "get_"
        @attributes[name.to_s.gsub(/get_/, '').to_sym]
      elsif name.to_s.start_with? "key_"
        if @attributes[name.to_s.gsub(/key_/, '').to_sym]
          name.to_s.gsub(/key_/, '').upcase
        end
      else
        @attributes[name] = args[0]
      end
    end
  end
end
