//
//  JumpAndScrollPositionController.swift
//  Pods-Demo
//
//  Created by Jérémy Marchand on 04/03/2018.
//

import Foundation
import GameController

// MARK: - Delegate
@objc
protocol RemoteActionPositionControllerDelegate {
    func remoteActionPositionControllerDidDetectTouch(_ vc: RemoteActionPositionController)
    func remoteActionPositionController(_ vc: RemoteActionPositionController, didSelectAction: RemoteActionPositionController.Action)
}

// MARK: - SurfaceRemotePositionController
class RemoteActionPositionController: NSObject, PositionController {
    
    
    enum Location {
        case left, center, right
    }
    
    
    
    @objc
    enum Action: Int {
        case fastForward, rewind, jumpForward, jumpBackward, reset, pause
        
        var images: (left: UIImage?, right: UIImage?) {
            let bundle = Bundle(identifier: "org.cocoapods.TVVLCPlayer")
            
            switch self {
            case .fastForward:
                return (nil, UIImage(named:  "Fast Forward", in: bundle, compatibleWith: nil))
            case .rewind:
                return (UIImage(named:  "Rewind", in: bundle, compatibleWith: nil), nil)
            case .jumpForward:
                return (nil, UIImage(named:  "SkipForward30", in: bundle, compatibleWith: nil))
            case .jumpBackward:
                return (UIImage(named: "SkipBack30", in: bundle, compatibleWith: nil), nil)
            default:
                return (nil, nil)
            }
        }
    }
    
    @IBOutlet weak var rightActionIndicator: UIImageView?
    @IBOutlet weak var leftActionIndicator: UIImageView?
    @IBOutlet weak var delegate: RemoteActionPositionControllerDelegate?

    var isEnabled: Bool = false {
        didSet {
            isEnabled ? trackSurfaceTouch() : untrackSurfaceTouch()
        }
    }
    
    private let gamePad = GCController.controllers().first?.microGamepad

    // MARK: State
    private var touchLocation: Location = .center {
        didSet {
            if touchLocation != oldValue {
                updateIndicators()
            }
        }
    }
    private var isLongPress = false {
        didSet {
            if isLongPress != oldValue {
                updateIndicators()
            }
        }
    }
    public func reset() {
        touchLocation = .center
        isLongPress = false
    }
    
    // MARK: Actions
    func longPressedActionForCurrentLocation() -> Action {
        switch self.touchLocation {
        case .left:
            return .rewind
        case .center:
            return .reset
        case .right:
            return .fastForward
        }
       
    }
    
    func actionOnPressEndForCurrentLocation() -> Action {
        switch self.touchLocation {
        case .left:
            return .jumpBackward
        case .center:
            return .pause
        case .right:
            return .jumpForward
        }
    }
    
    func actionForCurrentLocation() -> Action {
        if isLongPress {
            return longPressedActionForCurrentLocation()
        } else {
            return actionOnPressEndForCurrentLocation()
        }
    }
    
    
 
    // MARK: Indicators
    private func updateIndicators() {
        UIView.transition(with: leftActionIndicator!.superview!,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
                            guard let left = self.leftActionIndicator, let right = self.rightActionIndicator else {
                                return
                            }
                            
                            (left.image, right.image) = self.actionForCurrentLocation().images
        })
    }
    
    // MARK: Surface Touch
    private func trackSurfaceTouch() {
        gamePad?.reportsAbsoluteDpadValues = true
        gamePad?.dpad.valueChangedHandler = { (dpad: GCControllerDirectionPad, xValue: Float, yValue: Float) -> Void in
            
            if xValue > 0.5 {
                self.touchLocation = .right
            } else if xValue < -0.5 {
                self.touchLocation = .left
            } else {
                self.touchLocation = .center
            }
            
            self.delegate?.remoteActionPositionControllerDidDetectTouch(self)
        }
    }
    
    private func untrackSurfaceTouch() {
        gamePad?.dpad.valueChangedHandler = nil
        reset()
    }
    
    // MARK: IB Actions
    func click(_ sender: LongPressGestureRecogniser) {
        guard isEnabled else {
            return
        }
        
        switch sender.state {
        case .changed:
            self.isLongPress = sender.isLongPress
            if self.isLongPress {
                self.delegate?.remoteActionPositionController(self, didSelectAction: self.longPressedActionForCurrentLocation())
            }

        case .ended:
            
            if sender.isLongPress {
                self.delegate?.remoteActionPositionController(self, didSelectAction: .reset)
            } else {
                self.delegate?.remoteActionPositionController(self, didSelectAction: actionOnPressEndForCurrentLocation())
            }
            reset()

        default:
            break
        }
        
    }
    
    func playOrPause(_ sender: Any) {
        guard isEnabled else {
            return
        }
        
        reset()
        self.delegate?.remoteActionPositionController(self, didSelectAction: .pause)
    }
}

