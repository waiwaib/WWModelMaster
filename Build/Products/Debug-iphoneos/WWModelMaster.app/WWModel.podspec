
Pod::Spec.new do |s|

  s.name         = "WWModel"
  s.version      = "1.1.0"
  s.summary      = "A Entity Model Class for iOS"

  s.description  = <<-DESC
                   It Is A Entity Model Class for iOS, which implement by Objective-C.
                   DESC

  s.homepage     = "https://github.com/waiwaib/WWModelMaster"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  
  s.author             = { "waiwaib" => "857557118@qq.com" }
  
  
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/waiwaib/WWModelMaster.git", :tag => "1.0.9" }

  s.source_files  = "WWModelMaster/Model/*"
  
  s.frameworks = "Foundation"

  s.library     = "sqlite3"

  s.requires_arc = true
  
end
