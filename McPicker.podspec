#
# Be sure to run `pod lib lint McPicker.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'McPicker'
  s.version          = '0.2.0'
  s.summary          = 'McPicker is a UIPickerView drop-in solution with animations that is rotation ready.'

  s.description      = <<-DESC
McPicker is a UIPickerView replacement with animations and rotation ready. The more string arrays you pass the more picker components you'll get. You can set custom label or use the default.
DESC

  s.homepage         = 'https://github.com/kmcgill88/McPicker-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kevin McGill' => 'kevin@mcgilldevtech.com' }
  s.source           = { :git => 'https://github.com/kmcgill88/McPicker-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'McPicker/Classes/**/*'
  s.frameworks = 'UIKit'
end
