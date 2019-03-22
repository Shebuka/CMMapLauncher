Pod::Spec.new do |spec|
  spec.name         = "CMMapLauncher"
  spec.version      = "2.0.0"
  spec.summary      = "CMMapLauncher is a mini-library for iOS that makes it quick and easy to show directions in various mapping applications."
  spec.homepage     = "https://github.com/Shebuka/CMMapLauncher"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors      = { 'Citymapper', 'Shebuka' => 'shebuka@hotmail.com' }
  spec.platform     = :ios
  spec.source       = { :git => "https://github.com/shebuka/CMMapLauncher.git", :tag => "2.0.0" }
  spec.source_files = 'CMMapLauncher.{h,m}'
  spec.framework    = 'MapKit'
  spec.requires_arc = true
end
