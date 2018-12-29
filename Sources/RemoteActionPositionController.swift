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
    func remoteActionPositionControllerDidDetectTouch(_ : RemoteActionPositionController)
    func remoteActionPositionController(_ : RemoteActionPositionController, didSelectAction: RemoteActionPositionController.Action)
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
            let bundle = Bundle(for: RemoteActionPositionController.self)

            switch self {
            case .fastForward:
                return (nil, UIImage(named: "Fast Forward", in: bundle, compatibleWith: nil))
            case .rewind:
                return (UIImage(named: "Rewind", in: bundle, compatibleWith: nil), nil)
            case .jumpForward:
                return (nil, UIImage(named: "SkipForward30", in: bundle, compatibleWith: nil))
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

    // MARK: Deinit
    deinit {
        gamePad?.dpad.valueChangedHandler = nil
    }

    // MARK: State
    private var touchLocation: Location = .center {
        didSet {
            if touchLocation != oldValue {
                updateDisplayedAction()
            }
        }
    }
    private var isLongPress = false {
        didSet {
            if isLongPress != oldValue {
                updateDisplayedAction()
            }
        }
    }

    private var displayedAction: Action = .pause {
        didSet {
            if displayedAction != oldValue {
                updateIndicatorsImages()
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

    func actionOnPressEndedForCurrentLocation() -> Action {
        switch self.touchLocation {
        case .left:
            return .jumpBackward
        case .center:
            return .pause
        case .right:
            return .jumpForward
        }
    }

    private func updateDisplayedAction() {
        if isLongPress {
            displayedAction = longPressedActionForCurrentLocation()
        } else {
            displayedAction = actionOnPressEndedForCurrentLocation()
        }
    }

    // MARK: Indicators
    private func updateIndicatorsImages() {
        UIView.transition(with: leftActionIndicator!.superview!,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
                            guard let left = self.leftActionIndicator, let right = self.rightActionIndicator else {
                                return
                            }

                            (left.image, right.image) = self.displayedAction.images
        })
    }

    // MARK: Surface Touch
    private func trackSurfaceTouch() {
        gamePad?.reportsAbsoluteDpadValues = true
        gamePad?.dpad.valueChangedHandler = { [unowned self] dpad, xValue, yValue in

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
                self.delegate?.remoteActionPositionController(self, didSelectAction: actionOnPressEndedForCurrentLocation())
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
