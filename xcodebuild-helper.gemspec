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
  s.files         = `git ls-files`.split($\)
  s.require_paths = ['lib']
  s.executables   = s.files.grep(%r{^bin/}){ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(spec)})

  s.add_development_dependency "rspec"
  s.add_development_dependency "guard-rspec"
	s.add_development_dependency "rake"

  s.add_dependency "xcpretty"
  s.add_dependency "xcodeproj"
end
