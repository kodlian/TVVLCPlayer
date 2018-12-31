//
//  VLCPlayerViewController.swift
//  IndexOfTV
//
//  Created by Jérémy Marchand on 24/02/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import UIKit
import GameController
import TVVLCKit

/// `VLCPlayerViewController` is a subclass of `UIViewController` that can be used to display the visual content of an `VLCPlayer` object and the standard playback controls.
public class VLCPlayerViewController: UIViewController {
    public static func instantiate(media: VLCMedia) -> VLCPlayerViewController {
        let player = VLCMediaPlayer()
        player.media = media
        return instantiate(player: VLCMediaPlayer())
    }

    public static func instantiate(player: VLCMediaPlayer) -> VLCPlayerViewController {
        let storyboard = UIStoryboard(name: "TVVLCPlayer", bundle: Bundle(for: VLCPlayerViewController.self))
        guard let controller = storyboard.instantiateInitialViewController() as? VLCPlayerViewController else {
            fatalError()
        }
        controller.player = player
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

    @IBOutlet var actionGesture: LongPressGestureRecogniser!
    @IBOutlet var playPauseGesture: UITapGestureRecognizer!
    @IBOutlet var cancelGesture: UITapGestureRecognizer!

    @IBOutlet var scrubbingPositionController: ScrubbingPositionController!
    @IBOutlet var remoteActionPositionController: RemoteActionPositionController!

    /// Set the player.
    /// The player should be set before the view is loaded.
    public var player: VLCMediaPlayer = VLCMediaPlayer() {
        didSet {
            if isViewLoaded {
                fatalError("The VLCPlayer player should be set before the view is loaded.")
            }
            isOpening = true
            player.play()
        }
    }

    private var positionController: PositionController? {
        didSet {
            guard positionController !== oldValue else {
                return
            }
            oldValue?.isEnabled = false
            positionController?.isEnabled = true
        }
    }

    private var isOpening: Bool = false {
        didSet {
            guard self.viewIfLoaded != nil else {
                return
            }

            guard isOpening != oldValue else {
                return
            }

            if isOpening {
                openingIndicator.startAnimating()
            } else {
                openingIndicator.stopAnimating()
            }
            self.setUpPositionController()
        }
    }

    private var isBuffering: Bool = false {
        didSet {
            guard isBuffering != oldValue else {
                return
            }

            if isBuffering {
                bufferingIndicator.startAnimating()
            } else {
                bufferingIndicator.stopAnimating()

            }
            rightActionIndicator.isHidden = isBuffering
        }
    }

    private var lastSelectedPanelTabIndex: Int = 0
    private var displayedPanelViewController: UIViewController?
    private var isPanelDisplayed: Bool {
        return displayedPanelViewController != nil
    }

    public override var preferredUserInterfaceStyle: UIUserInterfaceStyle {
        return .dark
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        guard self.player.media != nil else {
            fatalError("The VLCPlayer player should contain a media before presenting player.")
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VLCPlayerViewController.mediaPlayerTimeChanged(_:)),
                                               name: NSNotification.Name(rawValue: VLCMediaPlayerTimeChanged),
                                               object: player)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VLCPlayerViewController.mediaPlayerStateChanged(_:)),
                                               name: NSNotification.Name(rawValue: VLCMediaPlayerStateChanged),
                                               object: player)

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
    @IBAction func click(_ sender: LongPressGestureRecogniser) {
        positionController?.click(sender)
    }
    @IBAction func playOrPause(_ sender: Any) {
        positionController?.playOrPause(sender)
    }

    @IBAction func showPanel(_ sender: Any) {
        self.performSegue(withIdentifier: "panel", sender: sender)
        setUpPositionController()
        hideControl()
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
        playbackControlHideTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
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

        guard let totalTime = player.totalTime,
            let value = time.value?.doubleValue,
            let totalValue = totalTime.value?.doubleValue else {
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
        guard player.isSeekable && !isOpening && !isPanelDisplayed else {
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
        actionGesture.isEnabled = playPauseGesture.isEnabled
    }

    fileprivate func handlePlaybackControlVisibility() {
        if player.state == .paused {
            showPlaybackControl()
        } else {
            autoHideControl()
        }
    }
}

// MARK: - VLC notifications
extension VLCPlayerViewController {

    @objc func mediaPlayerStateChanged(_ aNotification: Notification!) {
        setUpGestures()
        setUpPositionController()
        animateIndicatorsIfNecessary()
        handlePlaybackControlVisibility()

        if player.state == .ended || player.state == .error || player.state == .stopped {
            dismiss(animated: true)
        }
    }

    @objc func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        isOpening = false
        isBuffering = false

        updateViews(with: player.time)
    }
}

// MARK: - Scrubbling Delegate
extension VLCPlayerViewController: ScrubbingPositionControllerDelegate {
    func scrubbingPositionController(_ : ScrubbingPositionController, didScrubToTime time: VLCTime) {
        updateRemainingLabel(with: time)
    }

    func scrubbingPositionController(_ : ScrubbingPositionController, didSelectTime time: VLCTime) {
        player.time = time
        updateViews(with: time) // ?
        player.play()
    }
}

// MARK: - Remote Action Delegate
extension VLCPlayerViewController: RemoteActionPositionControllerDelegate {
    func remoteActionPositionControllerDidDetectTouch(_ : RemoteActionPositionController) {
        showPlaybackControl()
    }
    func remoteActionPositionController(_ : RemoteActionPositionController, didSelectAction action: RemoteActionPositionController.Action) {
        showPlaybackControl()

        switch action {
        case .fastForward:
            player.fastForward(atRate: 20.0)
        case .rewind:
            player.rewind(atRate: 20)
        case .jumpForward:
            player.jumpForward(30)
        case .jumpBackward:
            player.jumpBackward(30)
        case .pause:
            player.pause()
        case .reset:
            player.fastForward(atRate: 1.0)
        }
    }
}

// MARK: - Gesture
extension VLCPlayerViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Panel
extension VLCPlayerViewController {
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PanelViewController {
            destination.selectedIndex = lastSelectedPanelTabIndex
            destination.player = player
            destination.transitioningDelegate = self
            destination.delegate = self
            displayedPanelViewController = destination
        }
    }
}

extension VLCPlayerViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presented is PanelViewController ? SlideDownAnimatedTransitioner() : nil
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissed is PanelViewController ? SlideUpAnimatedTransitioner() : nil
    }
}

extension VLCPlayerViewController: PanelViewControllerDelegate {
    func panelViewController(_ panelViewController: PanelViewController, didSelectTabAtIndex index: Int) {
        lastSelectedPanelTabIndex = index
    }

    func panelViewControllerDidDismiss(_ panelViewController: PanelViewController) {
        displayedPanelViewController = nil
        setUpPositionController()
        handlePlaybackControlVisibility()
    }
}
