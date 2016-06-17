Pod::Spec.new do |s|

  s.name         = "MTUIKit"
  s.version      = "0.9.0"
  s.summary      = "A custom MTUIKit base on UIKit for Custom Control."
  s.homepage     = "http://techgit.meitu.com/iosmodules/MTUIKit"

  s.license      = {
    :type => 'Copyright',
    :text => <<-LICENSE
              © 2008-2016 Meitu. All rights reserved.
    LICENSE
  }

  s.author   = { "ph" => "ph@meitu.com" }
  s.platform     = :ios
  s.source       = { :git => "http://techgit.meitu.com/iosmodules/MTUIKit.git", :tag => "#{s.version}" }
  s.source_files  = "MTUIKit/**/*.{h,m}"
  s.public_header_files = 'MTUIKit/Public/*.h'
  s.frameworks = "UIKit"

  s.requires_arc = true

end
