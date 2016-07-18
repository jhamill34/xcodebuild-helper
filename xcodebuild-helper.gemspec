lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |s|
  s.name          = 'xcodebuild-helper'
  s.version       = XCodeBuildHelper::VERSION
  s.date          = '2016-03-30'
  s.summary       = 'DSL to help call xcode CLI more easliy'
  s.description   = 'Very useful when writing scripts to automate xcode development or when creating ci scripts to automate deployment'
  s.authors       = ['Joshua Rasmussen']
  s.email         = 'xlr8runner@gmail.com'
  s.require_paths = ['lib']
  s.executables   = s.files.grep(%r{^bin/}){ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(spec)})
	s.license				= 'MIT'
	s.homepage			= 'https://github.com/xlr8runner/xcodebuild-helper'

  s.add_development_dependency "rspec", ["~> 3.4"]
  s.add_development_dependency "guard-rspec", ["~> 4.6"]
	s.add_development_dependency "rake", ["~> 11.1"]

  s.add_dependency "xcpretty", ["~> 0.2"]
  s.add_dependency "xcodeproj", ["~> 0.28"]
  s.add_dependency "nokogiri", ["~> 1.6.7"]
end
