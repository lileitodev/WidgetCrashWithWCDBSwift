# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'WidgetCrashWithWCDBSwift' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WidgetCrashWithWCDBSwift
pod 'WCDB.swift', '~> 2.0.1'
end
target 'TestWidgetExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WidgetCrashWithWCDBSwift
pod 'WCDB.swift', '~> 2.0.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
