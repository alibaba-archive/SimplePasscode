#
#  Created by teambition-ios on 2020/7/27.
#  Copyright © 2020 teambition. All rights reserved.
#     

Pod::Spec.new do |s|
  s.name             = 'SimplePasscode'
  s.version          = '4.1.0'
  s.summary          = 'SimplePasscode'
  s.description      = <<-DESC
  SimplePasscode
                       DESC

  s.homepage         = 'https://github.com/teambition/SimplePasscode'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'teambition mobile' => 'teambition-mobile@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/teambition/SimplePasscode.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'

  s.source_files = 'Source/*.swift'
  s.ios.resource_bundle = { 'LocalizedString' => 'SimplePasscode/*.lproj/*' }

  s.dependency 'SnapKit'
  s.dependency 'SwiftDate'

end
