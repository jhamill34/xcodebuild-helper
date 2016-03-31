require 'xcode'
require 'execute'

module XCodeBuildHelper
  def self.build
    @@xcode.build
  end

  def self.define(name, &block)
    @@xcode = XCodeBuildHelper::XCode.new
    yield(@@xcode)
  end
end
