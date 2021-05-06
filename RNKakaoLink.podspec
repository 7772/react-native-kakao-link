Pod::Spec.new do |s|
  s.name         = "RNKakaoLink"
  s.version      = "1.0.0"
  s.summary      = "RNKakaoLink"
  s.description  = <<-DESC
                  RNKakaoLink
                   DESC
  s.homepage     = "http://olulo.io"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/author/RNKakaoLink.git", :tag => "master" }
  s.source_files  = "ios/*.{h,m}"
  s.requires_arc = true

  s.ios.deployment_target = '10.0'

  s.dependency "React"
  s.dependency "KakaoOpenSDK"

end
