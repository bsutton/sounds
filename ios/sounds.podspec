#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
s.name = 'sounds'
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
  s.dependency 'Flutter'

  s.ios.deployment_target = '9.3'
  s.static_framework = true
end
