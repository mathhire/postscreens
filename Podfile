# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
target 'Posters' do
  use_frameworks!
  
  pod 'IQKeyboardManagerSwift'
  pod 'SVProgressHUD'
 # pod 'UITextView+Placeholder'
  pod 'SDWebImage'
  pod 'Toast-Swift'
  pod 'Alamofire'
  pod 'AlamofireImage'
  pod 'CountryPickerView'
  pod 'CBPinEntryView'
  
  pod 'GoogleMaps'#, '6.2.1'
  pod 'GooglePlaces'
  pod 'TikTokOpenSDK', '~> 5.0.14'
  pod 'FSCalendar'
  pod 'BranchSDK'
  pod 'OneSignalXCFramework','>= 3.0.0', '< 4.0'

#pod 'ScrollFlowLabel'
#pod "EFAutoScrollLabel"

end
target 'OneSignalNotificationServiceExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'OneSignalXCFramework', '>= 3.0.0', '< 4.0'
end
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
