Pod::Spec.new do |s|
  s.name          = "Promises"
  s.version       = "1.0.0"
  s.summary       = "Promises toolkit for Swift."
  s.homepage      = "https://github.com/madyanov/Promises"
  s.license       = "MIT"
  s.author        = { "Roman Madyanov" => "romantaken@gmail.com" }
  s.source        = { :git => "https://github.com/madyanov/Promises.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*"
  s.framework     = "Foundation"
  s.swift_version = "4.2"

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.10"
end
