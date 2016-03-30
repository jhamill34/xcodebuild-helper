Gem::Specification.new do |s|
  s.name          = 'xcodebuild-helper'
  s.version       = '0.0.1'
  s.date          = '2016-03-30'
  s.summary       = 'Ruby gem to help call xcode methods more simply'
  s.description   = ''
  s.authors       = ['Joshua Rasmussen']
  s.email         = 'Josh.Rasmussen@discorp.com'
  s.files         = ['lib/*.rb']
  s.require_paths = ['lib']

  s.add_development_dependency "rspec"
  s.add_development_dependency "guard-rspec"

  s.add_dependency "xcpretty"
  s.add_dependency "xcodeproj"
end
