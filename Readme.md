# TVVLCPlayer

[![TVVLCPlayer](https://raw.githubusercontent.com/kodlian/TVVLCPlayer/master/thumbnail.png)](https://raw.githubusercontent.com/kodlian/TVVLCPlayer/master/screenshot.jpg)

TVVLCPlayer lets you integrate easily a powerfull video player with playback control views to your tvOS apps. Based on [TVVLCKit](https://code.videolan.org/videolan/VLCKit), it aims to replace AVPlayerViewController that can read only a limited number of formats.

## Features
- Native look & feel
- Scrubbling with remote surface touch
- Jump, fast forward and rewind

## Installation
```
# Carthage
github "kodlian/TVVLCPlayer", "~> 1.1.0"
```

```ruby
# CocoaPods
pod ":git => 'https://github.com/kodlian/TVVLCPlayer.git', :tag => "1.1.0"

pre_install do |installer|
	# workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
	Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end
```

## Usage
### Storyboard
In your storyboard add a reference to the `VLCPlayer` storyboard from the `com.kodlian.TVVLCPlayer` bundle if you use carthage or `org.cocoapods.TVVLCPlayer` bundle if you use cocoapods.
Then set a media on the playerViewController:
```swift
import TVVLCPlayer
...
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let playerViewController = segue.destination as? VLCPlayerViewController {
            let media: VLCMedia = ...
            playerViewController.media = media
      }
}

```

### In code
```swift
import TVVLCPlayer
...
let media: VLCMedia = ...
let playerViewController = VLCPlayerViewController.instantiate(media: media)
```

## Todo
- [ ] Audio channels selector
- [ ] Subtitles selector
- [ ] Info views
