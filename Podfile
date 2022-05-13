# Uncomment this line to define a global platform for your project
platform :ios, '13.0'

target 'Colorue' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Colorue
  pod 'R.swift','~>6'
  pod 'RealmSwift','~>10'
  pod 'PureLayout','~>3'
end

target 'ColorueWidgetExtension' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ColorueWidgetExtension
  pod 'RealmSwift','~>10'
  pod 'PureLayout','~>3'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
