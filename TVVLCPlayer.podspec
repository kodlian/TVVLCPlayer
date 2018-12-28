Pod::Spec.new do |s|
  s.name             = "TVVLCPlayer"
  s.version          = "1.1.0"
  s.summary          = "A powerfull video player"

  s.description      = <<-DESC
  TVVLCPlayer lets you integrate easylily a powerfull video player with playback control views to your tv apps.
   Based on TVVLCKit, it aims to replace AVPlayerViewController that can read only a limited number of formats.
                       DESC
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
  s.resources = ['Resources/*.storyboard','Resources/*.xcassets']
  s.script_phase = { :name => 'Add modulemaps in VLCKit', :script => 'cp -rf "${PODS_TARGET_SRCROOT}/Modules" "${PODS_ROOT}/TVVLCKit/TVVLCKit.framework/Modules"', :execution_position => :before_compile }
  s.preserve_path = "Modules"
end
