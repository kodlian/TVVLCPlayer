//
//  VLCPlayerViewController.swift
//  IndexOfTV
//
//  Created by Jérémy Marchand on 24/02/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import UIKit
import GameController

public class VLCPlayerViewController: UIViewController {
    public static func instantiate(media: VLCMedia) -> VLCPlayerViewController {
        let storyboard = UIStoryboard(name: "TVVLCPlayer", bundle: Bundle(for: VLCPlayerViewController.self))
        let controller = storyboard.instantiateInitialViewController() as! VLCPlayerViewController
        controller.media = media
        return controller
    }
  
    @IBOutlet var videoView: UIView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var transportBar: ProgressBar!
    @IBOutlet weak var scrubbingLabel: UILabel!
    @IBOutlet weak var playbackControlView: GradientView!
    @IBOutlet weak var rightActionIndicator: UIImageView!

    @IBOutlet weak var positionConstraint: NSLayoutConstraint!
    @IBOutlet weak var bufferingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var openingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var actionGesture: UITapGestureRecognizer!
    @IBOutlet var playPauseGesture: UITapGestureRecognizer!
    @IBOutlet var cancelGesture: UITapGestureRecognizer!
    
    @IBOutlet var scrubbingPositionController: ScrubbingPositionController!
    @IBOutlet var remoteActionPositionController: RemoteActionPositionController!

    public var media: VLCMedia? {
        didSet {
            player.media = media
        }
    }
    
    private var positionController: PositionController? {
        didSet {
            oldValue?.isEnabled = false
            positionController?.isEnabled = true
        }
    }
    
    private var isBuffering: Bool = false {
        didSet {
            if isBuffering {
                bufferingIndicator.startAnimating()
            } else {
                bufferingIndicator.stopAnimating()
                
            }
            rightActionIndicator.isHidden = isBuffering
        }
    }
    
    public let player = VLCMediaPlayer()
    
    public override var preferredUserInterfaceStyle: UIUserInterfaceStyle {
        return .dark
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = self.media else {
            fatalError("Should define a media before presenting player.")
        }
        
        player.delegate = self
        player.drawable = videoView
        player.play()
        playbackControlView.isHidden = true
        openingIndicator.startAnimating()

        let font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: UIFont.Weight.medium)
        remainingLabel.font = font
        positionLabel.font = font
        scrubbingLabel.font = font
        
        scrubbingPositionController.player = player
        
        setUpGestures()
        setUpPositionController()
        updateViews(with: player.time)
        animateIndicatorsIfNecessary()
    }
    
    deinit {
        player.stop()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 

    // MARK: IB Actions
    @IBAction func click(_ sender: Any) {
        positionController?.click(sender)
    }
    @IBAction func playOrPause(_ sender: Any) {
        positionController?.playOrPause(sender)
    }
    
    // MARK: Control
    var playbackControlHideTimer: Timer?
    public func showPlaybackControl() {
        playbackControlHideTimer?.invalidate()
        if player.state != .paused {
            autoHideControl()
        }
        
        guard self.playbackControlView.isHidden else {
            return
        }
        self.cancelGesture.isEnabled = true
        
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.playbackControlView.isHidden = false
        })
        
       
    }
    
    private func autoHideControl() {
        playbackControlHideTimer?.invalidate()
        playbackControlHideTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            self.hideControl()
        }
    }
    
    private func hideControl() {
        playbackControlHideTimer?.invalidate()
        self.cancelGesture.isEnabled = false
        
        guard !self.playbackControlView.isHidden else {
            return
        }
        
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.playbackControlView.isHidden = true
        })
    }
    
    @IBAction func cancel(_ sender: Any) {
        player.play()
        hideControl()
    }
}


// MARK: - Update views
extension VLCPlayerViewController {
    fileprivate func updateViews(with time: VLCTime) {
        positionLabel.text = time.stringValue

        guard let totalTime = player.totalTime, let value = time.value?.doubleValue, let totalValue = totalTime.value?.doubleValue else {
            remainingLabel.isHidden = true
            positionConstraint.constant = transportBar.bounds.width / 2
            return
        }
        
        positionConstraint.constant = round(CGFloat(value / totalValue) * transportBar.bounds.width)
        remainingLabel.isHidden = positionConstraint.constant + positionLabel.frame.width > remainingLabel.frame.minX - 60
    }
    
    fileprivate func updateRemainingLabel(with time: VLCTime) {
        guard let totalTime = player.totalTime, totalTime.value != nil else {
            return
        }
        remainingLabel.text = (totalTime - time).stringValue
    }
    
    fileprivate func setUpPositionController() {
        guard player.isSeekable  else {
            positionController = nil
            return
        }
        
        if player.state == .paused {
            scrubbingPositionController.selectedTime = player.time
            positionController = scrubbingPositionController
        } else {
            positionController = remoteActionPositionController
        }
    }
    
    fileprivate func animateIndicatorsIfNecessary() {
        if player.state == .opening {
            openingIndicator.startAnimating()
        }
        if player.state == .buffering && player.isPlaying {
            isBuffering = true
        }
    }
    fileprivate func setUpGestures() {
        playPauseGesture.isEnabled = player.state != .opening && player.state != .stopped
    }
    
    fileprivate func handlePlaybackControlVisibility() {
        if player.state == .paused {
            showPlaybackControl()
        } else {
            autoHideControl()
        }
    }
}




// MARK: - VLC Delegate
extension VLCPlayerViewController: VLCMediaPlayerDelegate {

    public func mediaPlayerStateChanged(_ aNotification: Notification!) {
        setUpGestures()
        setUpPositionController()
        animateIndicatorsIfNecessary()
        handlePlaybackControlVisibility()
        
        if player.state == .ended || player.state == .error || player.state == .stopped {
            dismiss(animated: true)
        }
    }
    
    public func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        openingIndicator.stopAnimating()
        isBuffering = false

        updateViews(with: player.time)
    }
    
}


// MARK: - Scrubbling Delegate
extension VLCPlayerViewController: ScrubbingPositionControllerDelegate {
    func scrubbingPositionController(_ vc: ScrubbingPositionController, didScrubToTime time: VLCTime) {
        updateRemainingLabel(with: time)
    }
    
    func scrubbingPositionController(_ vc: ScrubbingPositionController, didSelectTime time: VLCTime) {
        player.time = time
        updateViews(with: time) // ?
        player.play()
    }
}

// MARK: - Remote Action Delegate
extension VLCPlayerViewController: RemoteActionPositionControllerDelegate {
    func remoteActionPositionControllerDidDetectTouch(_ vc: RemoteActionPositionController) {
        showPlaybackControl()
    }
    func remoteActionPositionController(_ vc: RemoteActionPositionController, didSelectAction action: RemoteActionPositionController.Action) {
        showPlaybackControl()

        switch action {
        case .forward:
            player.jumpForward(30)
        case .backward:
            player.jumpBackward(30)
        case .neutral:
            player.pause()
        }
    }
}

// MARK: - Gesture
extension VLCPlayerViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
