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
    @IBOutlet weak var scrubbingView: UIView!
    @IBOutlet weak var scrubbingPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var delegate: ScrubbingPositionControllerDelegate?

    var player: VLCMediaPlayer! = nil
    var isEnabled: Bool = false {
        didSet {
            decelerateTimer?.invalidate()
            scrubbingGesture.isEnabled = isEnabled
            selectedTime = player.time
            
            scrubbingView.isHidden = !isEnabled

        }
    }
    
    private var lastTranslation: CGFloat = 0.0
    private var decelerateTimer: Timer?
    private var selectedTime: VLCTime = VLCTime() { // Animate scrubbing view hidden
        didSet {
            guard let totalTime = player.totalTime else {
                fatalError("ScrubbingPositionController supports only video with a total time")
            }
            
            let value = selectedTime.value.doubleValue
            let totalTimeValue = totalTime.value.doubleValue
            scrubbingPositionConstraint.constant = round(CGFloat(value / totalTimeValue) * transportBar.bounds.width)
            scrubbingLabel.text = selectedTime.stringValue
            // remainingLabel.text = (totalTime - selectedTime).stringValue
            
            
            //        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            //            if activateSlider {
            //                self.sliderView.isHidden = false
            //            } else {
            //                self.sliderView.isHidden = true
            //            }
            //        })
        }
    }
    
    // MARK: IB Actions
    @IBAction func scrub(_ sender: UIPanGestureRecognizer) {
        decelerateTimer?.invalidate()
        
        switch sender.state {
        case .cancelled:
            selectedTime = player.time!
            fallthrough
        case .ended:
            let velocity = sender.velocity(in: nil)
            let factor = abs(velocity.x / transportBar.bounds.width)
            moveByDeceleratingPosition(by: lastTranslation * factor / 8)
            lastTranslation = 0.0
            
        case .began:
            fallthrough
            
        case .changed:
            let translation = sender.translation(in: nil)
            movePosition(by: (translation.x - lastTranslation) / 8)
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
    
    func click(_ sender: Any) {
        self.playOrPause(sender)
    }
    
    // MARK: Movement
    private func moveByDeceleratingPosition(by translation: CGFloat) {
        decelerateTimer?.invalidate()
        if abs(translation) > 1 {
            decelerateTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { (timer: Timer) in
                self.movePosition(by: translation / 64)
                self.moveByDeceleratingPosition(by: translation * 0.9)
            }
        }
    }
    
    private func movePosition(by offset: CGFloat) {
        guard let totalTime = player?.totalTime else {
            return
        }
        var newPosition = scrubbingPositionConstraint.constant + offset
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
