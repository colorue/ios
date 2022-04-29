# Uncomment this line to define a global platform for your project
 platform :ios, '13.0'

target 'Colorue' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Colorue
  #    pod 'Firebase/Core'
  #    pod 'Firebase/Database'
  #    pod 'Firebase/Auth'
  #    pod 'Firebase/Messaging'
  #    pod 'Firebase/Storage'
  #    pod 'Firebase/Crash'
  #    pod 'Kingfisher'

    pod 'R.swift'
    pod 'Toast-Swift', '~> 5.0.1'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end

