#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sounds.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name 	     = 'sounds'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin that provides audio recording and playback services.'
  s.description      = <<-DESC
Flutter plugin that provides audio recording and playback services
                       DESC
  s.homepage         = 'http://github.com/bsutton/sounds'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Sounds' => 'bsutton@noojee.com.au' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.vendored_frameworks = 'Flutter.framework'
  #s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  s.ios.deployment_target = '10.0'
   # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
   s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
   s.swift_version = '5.0'
end
