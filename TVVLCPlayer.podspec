Pod::Spec.new do |s|
  s.name             = "TVVLCPlayer"
  s.version          = "1.0.2"
  s.summary          = "A powerfull video player"

  s.description      = <<-DESC
  TVVLCPlayer lets you integrate easylily a powerfull video player with playback control views to your tv apps.
   Based on TVVLCKit, it aims to replace AVPlayerViewController that can read only a limited number of formats.
                       DESC
  s.static_framework = true
  s.homepage         = "https://github.com/kodlian/TVVLCPlayer"
  s.screenshots      =  "https://raw.githubusercontent.com/kodlian/TVVLCPlayer/master/screenshot.jpg"
  s.license          = 'MIT'
  s.author           = "Jérémy Marchand"
  s.source           = { :git => "https://github.com/kodlian/TVVLCPlayer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/kodlian'
  s.swift_version    = '4.0'
  s.tvos.deployment_target = '11.0'

  s.source_files = 'Sources/*.{swift,h}'

  s.frameworks = 'UIKit'
  s.dependency 'TVVLCKit'
  s.pod_target_xcconfig = {
      'SWIFT_OBJC_BRIDGING_HEADER' => "${PODS_TARGET_SRCROOT}/Sources/TVVLCPlayer-Bridging-Header.h"
  }
  s.resources = ["Resources/*.storyboard"]
  s.resource_bundle = { 'TVVLCPlayer' => [ 'Resources/*.xcassets' ] }

end
