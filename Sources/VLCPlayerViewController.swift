//
//  VLCPlayerViewController.swift
//  IndexOfTV
//
//  Created by Jérémy Marchand on 24/02/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import UIKit

public class VLCPlayerViewController: UIViewController {
    public static func instantiate(media: VLCMedia) -> VLCPlayerViewController {
        let storyboard = UIStoryboard(name: "TVVLCPlayer", bundle: Bundle(for: VLCPlayerViewController.self))
        let controller = storyboard.instantiateInitialViewController() as! VLCPlayerViewController
        return controller
    }
    
    @IBOutlet var videoView: UIView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var progressBar: ProgressBar!
    
    @IBOutlet weak var controlView: GradientView!
    @IBOutlet weak var positionConstraint: NSLayoutConstraint!
    @IBOutlet weak var positionSliderConstraint: NSLayoutConstraint!
    @IBOutlet weak var bufferingIndocator: UIActivityIndicatorView!
    @IBOutlet weak var openingIndicator: UIActivityIndicatorView!
    @IBOutlet var showGesture: UITapGestureRecognizer!
    
    @IBOutlet var playGesture: UITapGestureRecognizer!
    @IBOutlet var sliderGesture: UIPanGestureRecognizer!
    @IBOutlet var cancelGesture: UITapGestureRecognizer!
    
    public var url: URL! = URL(string: "https://upload.wikimedia.org/wikipedia/commons/8/88/Big_Buck_Bunny_alt.webm")!
    let player = VLCMediaPlayer()
    var sliderTime: VLCTime?
    
    public override var preferredUserInterfaceStyle: UIUserInterfaceStyle {
        return .dark
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let media = VLCMedia(url: url)
        player.media = media
        player.delegate = self
        player.drawable = videoView
        player.play()
        controlView.isHidden = true
        openingIndicator.startAnimating()

        let font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: UIFont.Weight.medium)
        remainingLabel.font = font
        positionLabel.font = font
        sliderLabel.font = font
    }
    
    deinit {
        player.stop()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 

    // MARK: Slider
    var lastTranslation: CGFloat = 0.0
    @IBAction func changePosition(_ sender: UIPanGestureRecognizer) {
        decelerateTimer?.invalidate()

        switch sender.state {
        case .cancelled:
            sliderTime = nil
            fallthrough
        case .ended:
            let velocity = sender.velocity(in: view)
            let factor = abs(velocity.x / progressBar.bounds.width)
            moveByDeceleratingSliderPosition(by: lastTranslation * factor / 8)
            lastTranslation = 0.0

        case .began:
            fallthrough
            
        case .changed:
            let translation = sender.translation(in: view)
            moveSliderPosition(by: (translation.x - lastTranslation) / 8)
            lastTranslation = translation.x
            
        default:
            return
        }
    }
    var decelerateTimer: Timer?
    func moveByDeceleratingSliderPosition(by translation: CGFloat) {
        decelerateTimer?.invalidate()
        if abs(translation) > 1 {
            decelerateTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { (timer: Timer) in
                self.moveSliderPosition(by: translation / 64)
                self.moveByDeceleratingSliderPosition(by: translation * 0.9)
            }
        }
    }
    
    func moveSliderPosition(by offset: CGFloat) {
        guard let totalTime = player.totalTime, player.state == .paused else {
            return
        }
        var newPosition = positionSliderConstraint.constant + offset
        if newPosition < 0 {
            newPosition = 0
        } else if newPosition > progressBar.bounds.width {
            newPosition = progressBar.bounds.width
        }
        
        let time = totalTime * Double(newPosition / progressBar.bounds.width)
        positionSliderConstraint.constant = newPosition
        sliderTime = time
        sliderLabel.text = time.stringValue
        remainingLabel.text = (totalTime - time).stringValue
    }
    
    // MARK: Action
    @IBAction func togglePlay(_ sender: Any) {
        if player.isPlaying {
            player.pause()
            showControl(sender)
            
        } else {
            if let time = sliderTime {
                player.time = time
                positionConstraint.constant = positionSliderConstraint.constant
                positionLabel.text = time.stringValue
                remainingLabel.isHidden = positionSliderConstraint.constant + progressBar.frame.minX  > remainingLabel.frame.minX - 60

            }
            if player.state == .stopped {
                player.time = VLCTime(int: 0)
            }
            sliderTime = nil
            player.play()
            autoHideControl()
        }
    }
    
    // MARK: Control
    var timer: Timer?
    @IBAction func showControl(_ sender: Any) {
        timer?.invalidate()

        guard self.controlView.isHidden else {
            return
        }
        self.cancelGesture.isEnabled = true
        
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.controlView.isHidden = false
        })
    }
    
    func autoHideControl() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
            self.hideControl()
        }
    }
    
    func hideControl() {
        timer?.invalidate()
        self.cancelGesture.isEnabled = true
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.controlView.isHidden = true
        })
    }
    
    @IBAction func cancel(_ sender: Any) {
        sliderTime = nil
        player.play()
        hideControl()
    }
}



// MARK: - VLC Delegate
extension VLCPlayerViewController: VLCMediaPlayerDelegate {
    public func mediaPlayerStateChanged(_ aNotification: Notification!) {
        print(self.player.isSeekable)
        print(self.player.time.value)

        
        let activateSlider = self.player.state == .paused && self.player.isSeekable && self.player.time.value != nil
        self.sliderGesture.isEnabled = activateSlider
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            if activateSlider {
                self.sliderView.isHidden = false
            } else {
                self.sliderView.isHidden = true
            }
        })
        
        if player.state == .buffering && player.isPlaying {
            bufferingIndocator.startAnimating()
        } else {
            bufferingIndocator.stopAnimating()
        }
        
        //playGesture.isEnabled = player.state != .opening
    }
    
    public func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        openingIndicator.stopAnimating()
        playGesture.isEnabled = true
        bufferingIndocator.stopAnimating()
     
        positionLabel.text = player.time.stringValue
        remainingLabel.text = player.remainingTime.stringValue
        sliderLabel.text = positionLabel.text
    
        positionConstraint.constant = round(CGFloat(player.position) * progressBar.bounds.width)
        positionSliderConstraint.constant = positionConstraint.constant
    
        remainingLabel.isHidden = positionLabel.frame.maxX > remainingLabel.frame.minX - 60
    }
    
}

// MARK: - Gesture
extension VLCPlayerViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true

    }
}
