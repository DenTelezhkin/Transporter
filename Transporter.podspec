
Pod::Spec.new do |s|
  s.name         = "Transporter"
  s.version      = "0.1.0"
  s.summary      = "Modern finite-state machine implemented in pure Swift"

  s.homepage     = "https://github.com/DenHeadless/Transporter"
  s.license      = "MIT"
  s.author             = { "Denys Telezhkin" => "denys.telezhkin@yandex.ru" }
  s.social_media_url   = "http://twitter.com/DTCoder"
  
  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"

  s.source       = { :git => "https://github.com/DenHeadless/Transporter.git", :tag => s.version.to_s }
  s.source_files  = "Code/*.{swift}"
  s.framework  = "Foundation"
  s.requires_arc = true
end
