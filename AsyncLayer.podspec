Pod::Spec.new do |s|

s.name         = "AsyncLayer"
s.version      = "1.0.0"
s.summary      = "高性能异步渲染Layer"

s.homepage     = "https://github.com/lixiang1994/AsyncLayer"

s.license      = "MIT"

s.author       = { "LEE" => "18611401994@163.com" }

s.platform     = :ios
s.platform     = :ios, "9.0"

s.source       = { :git => "https://github.com/lixiang1994/AsyncLayer.git", :tag => "1.0.0"}

s.source_files  = "AsyncLayer/**/*.swift"

s.requires_arc = true

s.swift_version = "4.2"

end
