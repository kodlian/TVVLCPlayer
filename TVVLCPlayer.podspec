Pod::Spec.new do |s|
  s.name             = "TVVLCPlayer"
  s.version          = "1.0.0"
  s.summary          = "A powerfull video player"

  s.description      = <<-DESC
  TVVLCPlayer lets you integrate easylily a powerfull video player with control views to your tv apps.
   Based on TVVLCKit, it aims to replace AVPlayerViewController that can read only a limited number of formats.
                       DESC

  s.homepage         = "https://github.com/kodlian/TVVLCPlayer"
  s.screenshots     = "https://raw.githubusercontent.com/kodlian/TVVLCPlayer/master/Assets/slider.png"
  s.license          = 'MIT'
  s.author           = "Jérémy Marchand"
  s.source           = { :git => "https://github.com/kodlian/TVVLCPlayer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/kodlian'

  s.tvos.deployment_target = '11.0'

  s.source_files = 'Sources/*.{h,swift}'
  s.resource_bundles = {
    'TVVLCPlayer' => ['Sources/*.storyboard']
  }
  s.frameworks = 'UIKit'
  spec.dependency 'TVVLCKit'

end
