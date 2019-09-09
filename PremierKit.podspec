Pod::Spec.new do |s|
  s.name             = "PremierKit"
  s.version          = "6.2.1"
  s.summary          = "Base code for iOS apps"
  s.homepage         = "https://github.com/ricardopereira/PremierKit"
  s.license          = 'MIT'
  s.author           = { "Ricardo Pereira" => "m@ricardopereira.eu" }
  s.source           = { :git => "https://github.com/ricardopereira/PremierKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ricardopereiraw'

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.swift_version = '5.0'

  s.source_files = 'PremierKit/*.{h}', 'Source/**/*.{h,swift}'
  s.frameworks = 'UIKit'
end
