# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'BetIT' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BetIT
    #Constraint
    pod 'SnapKit'
    
    #Object Modeling
    pod 'ObjectMapper'
    
    #Keyboard
    pod 'IQKeyboardManagerSwift'
    
    #Localization
    pod 'Localize-Swift'

    #Network
    pod 'SVProgressHUD'
    pod 'Alamofire'
  	pod 'AlamofireObjectMapper', '~> 5.2'
    pod 'PromiseKit'
    
    #Calendar
    pod 'FSCalendar'
    
    #JSON Kit
    pod 'SwiftyJSON'
    
    #Keychain
    pod 'KeychainSwift'
    
    #Image
    pod 'SDWebImage'
	
	# Firebase 
	pod 'Fabric'
	pod 'Crashlytics'
	pod 'Firebase/Auth'
	pod 'Firebase/Core'
	pod 'Firebase/Firestore'
  	pod 'Firebase/Storage'
  	pod 'FirebaseUI/Storage'
  	pod 'Firebase/Messaging'

	pod 'Branch'

    pod 'FBSDKLoginKit'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    #    if target.name == 'SnapKit' ||
    #      target.name == 'ObjectMapper' ||
    #      target.name == 'IQKeyboardManagerSwift'
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.2'
    end
    #    end
  end
end

