module XCodeBuildHelper
  class Device
    def platform(name)
      @platform = name
    end

    def get_platform
      @platform
    end

    def name (device_name)
      @device_name = device_name
    end

    def get_name
      @device_name
    end

    def os (name)
      @os = name
    end

    def get_os
      @os
    end
  end
end
