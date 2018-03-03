# TVVLCPlayer

![TVVLCPlayer ](https://raw.githubusercontent.com/kodlian/Albatross/master/thumbnail.jpg)

TVVLCPlayer lets you integrate easylily a powerfull video player with control views to your tv apps. Based on [TVVLCKit]()https://code.videolan.org/videolan/VLCKit, it aims to replace AVPlayerViewController that can read only a limited number of formats.

## Usage
### Storyboard
In your storyboard add a reference to the VLCPlayerViewController from TVVLCPlayer module

```swift
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let playerViewController = segue.destination as? VLCPlayerViewController {
            let media: VLCMedia = ...
            playerViewController.media = media
      }
 }

```
### In code
```swift
let media: VLCMedia = ...
let playerViewController = VLCPlayerViewController()
playerViewController.media = media
```

## Installation

```ruby
# CocoaPods 
pod "TVVLCPlayer", "~> 1.0"

# Carthage
github "kodlian/TVVLCPlayer" ~> 1.0
```

## Todo
- [ ] Audio channels selector
- [ ] Subtitles selector
- [ ] Media info panel




