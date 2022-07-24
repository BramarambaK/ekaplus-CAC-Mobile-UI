# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'


  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for EkaAnalytics


def available_pods
  pod 'TrustKit'
  pod 'jot'
  pod "FlexiblePageControl", :git => "https://github.com/shima11/FlexiblePageControl.git"
  pod 'Highcharts'
  pod 'GoogleAnalytics'
  pod 'Intercom', '~> 5.4.1'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Crashlytics'
  pod 'Bagel', '~>  1.3.2'
  pod 'MSAL'
  pod 'OktaOidc'
  pod 'JWTDecode', '~> 2.4'

end


target 'EkaAnalytics' do
    available_pods
end

target 'EkaAnalyticsQA' do
    available_pods
end

post_install do |installer|
    copy_pods_resources_path = "Pods/Target Support Files/Pods-EkaAnalytics/Pods-EkaAnalytics-resources.sh"
    string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
    assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
    text = File.read(copy_pods_resources_path)
    new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
    File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }
end
