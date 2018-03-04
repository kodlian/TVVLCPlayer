//
//  SliderPositionController.swift
//  Pods-Demo
//
//  Created by Jérémy Marchand on 04/03/2018.
//

import Foundation

// MARK: Delegate
@objc
protocol ScrubbingPositionControllerDelegate {
    func scrubbingPositionController(_ vc: ScrubbingPositionController, didScrubToTime: VLCTime)
    func scrubbingPositionController(_ vc: ScrubbingPositionController, didSelectTime: VLCTime)
}


// MARK: ScrubbingPositionController
class ScrubbingPositionController: NSObject, PositionController {
    @IBOutlet var scrubbingGesture: UIPanGestureRecognizer!
    @IBOutlet weak var transportBar: ProgressBar!
    @IBOutlet weak var scrubbingLabel: UILabel!
    @IBOutlet weak var scrubbingBar: UIView!
    @IBOutlet weak var scrubbingView: UIView!
    @IBOutlet weak var scrubbingPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var delegate: ScrubbingPositionControllerDelegate?

    var player: VLCMediaPlayer! = nil
    var isEnabled: Bool = false {
        didSet {
            decelerateTimer?.invalidate()
            scrubbingGesture.isEnabled = isEnabled
    
            DispatchQueue.main.async {
                self.toggleScrubbingViewVisibility()
            }
        }
    }
    var selectedTime: VLCTime = VLCTime() { // Animate scrubbing view hidden
        didSet {
            guard let totalTime = player.totalTime else {
                fatalError("ScrubbingPositionController supports only video with a total time")
            }
            
            let value = selectedTime.value.doubleValue
            let totalTimeValue = totalTime.value.doubleValue
            scrubbingPositionConstraint.constant = round(CGFloat(value / totalTimeValue) * transportBar.bounds.width)
            scrubbingLabel.text = selectedTime.stringValue
        }
    }
    
    private var lastTranslation: CGFloat = 0.0
    private var decelerateTimer: Timer?

    // MARK:Visibility
    func toggleScrubbingViewVisibility() {
        let transform = CGAffineTransform(translationX: 0, y: scrubbingBar.bounds.height).scaledBy(x: 0.1, y: 0.1)
        print(isEnabled)

        if isEnabled && scrubbingView.isHidden {
            scrubbingView.isHidden = false
            scrubbingView.transform = transform
            UIView.animate(withDuration: 0.2, animations: {
                self.scrubbingView.transform = CGAffineTransform.identity
            })
        } else if !isEnabled && !scrubbingView.isHidden {
            scrubbingView.transform = CGAffineTransform.identity
            UIView.animate(withDuration: 0.2, animations: {
                self.scrubbingView.transform = transform
            }) { _ in
                self.scrubbingView.isHidden = true
            }
        }
    }
    
    // MARK: IB Actions
    let surfaceTouchScreenFactor: CGFloat = 1 / 8
    @IBAction func scrub(_ sender: UIPanGestureRecognizer) {
        decelerateTimer?.invalidate()
        
        switch sender.state {
        case .cancelled:
            selectedTime = player.time!
            fallthrough
        case .ended:
            let velocity = sender.velocity(in: nil)
            let factor = abs(velocity.x / transportBar.bounds.width * surfaceTouchScreenFactor)
            moveByDeceleratingPosition(by: factor * lastTranslation * surfaceTouchScreenFactor)
            lastTranslation = 0.0
            
        case .began:
            fallthrough
            
        case .changed:
            let translation = sender.translation(in: nil)
            movePosition(to: scrubbingPositionConstraint.constant + (translation.x - lastTranslation) * surfaceTouchScreenFactor)
            lastTranslation = translation.x
            
        default:
            return
        }
    }
    
    func playOrPause(_ sender: Any) {
        guard isEnabled else {
            return
        }
        delegate?.scrubbingPositionController(self, didSelectTime: selectedTime)
    }
    
    func click(_ sender: LongPressGestureRecogniser) {
        guard sender.state == .ended && !sender.isLongPress else {
            return
        }
        self.playOrPause(sender)

    }
    
    // MARK: Movement
    let numberOfFrames: CGFloat = 100
    private func moveByDeceleratingPosition(by translation: CGFloat) {
        decelerateTimer?.invalidate()
        if abs(translation) > 1 {
            var frame: CGFloat = 0
            
            print("change \(translation)")
            let startPosition = scrubbingPositionConstraint.constant
            decelerateTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer: Timer) in
                let position = easeOut(time: frame, change: translation, startPosition: startPosition, duration: self.numberOfFrames)
                frame += 1
                self.movePosition(to: position)
                
                if frame > self.numberOfFrames {
                      self.decelerateTimer?.invalidate()
                }
            }
        }
    }
    
    private func movePosition(to position: CGFloat) {
        guard let totalTime = player?.totalTime else {
            return
        }
        var newPosition = position
        if newPosition < 0 {
            newPosition = 0
        } else if newPosition > transportBar.bounds.width {
            newPosition = transportBar.bounds.width
        }
        
        let time = totalTime * Double(newPosition / transportBar.bounds.width)
        selectedTime = time
        delegate?.scrubbingPositionController(self, didScrubToTime: selectedTime)
    }
}

// MARK: EaseOut function
func easeOut(time: CGFloat, change: CGFloat, startPosition: CGFloat, duration: CGFloat) -> CGFloat {
    var t: CGFloat = time / duration;
    t -= 1
    return change * (t*t*t + 1) + startPosition
}
