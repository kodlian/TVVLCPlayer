# TVVLCPlayer

[![TVVLCPlayer](https://raw.githubusercontent.com/kodlian/TVVLCPlayer/master/thumbnail.jpg)](https://raw.githubusercontent.com/kodlian/TVVLCPlayer/master/screenshot.jpg)

TVVLCPlayer lets you integrate easylily a powerfull video player with playback control views to your tv apps. Based on [TVVLCKit](https://code.videolan.org/videolan/VLCKit), it aims to replace AVPlayerViewController that can read only a limited number of formats.

## Features
- Native look & feel
- Scrubbling with remote surface touch
- Jump, fast forward and rewind

## Installation
```ruby
# CocoaPods
pod "TVVLCPlayer", "~> 1.0"
```

## Usage
### Storyboard
In your storyboard add a reference to the VLCPlayer storyboard from the org.cocoapods.TVVLCPlayer bundle.
Then set a media on the playerViewController:
```swift
import TVVLCKit
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
import TVVLCKit
...
let media: VLCMedia = ...
let playerViewController = VLCPlayerViewController.instantiate(media: media)
```

## Todo
- [ ] Audio channels selector
- [ ] Subtitles selector
- [ ] Info views
