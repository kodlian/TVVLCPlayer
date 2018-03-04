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
    
    @objc
    enum Action: Int {
        case forward, backward, neutral
        
        var image: UIImage? {
            let bundle = Bundle(identifier: "org.cocoapods.TVVLCPlayer")
            
            switch self {
            case .forward:
                return UIImage(named:  "SkipForward30", in: bundle, compatibleWith: nil)
            case .backward:
                return UIImage(named: "SkipBack30", in: bundle, compatibleWith: nil)
            case .neutral:
                return nil
            }
        }
    }
    
    @IBOutlet weak var rightActionIndicator: UIImageView?
    @IBOutlet weak var leftActionIndicator: UIImageView?
    @IBOutlet weak var delegate: RemoteActionPositionControllerDelegate?

    var isEnabled: Bool = false {
        didSet {
            isEnabled ? trackSurfaceTouch() : untrackSurfaceTouch()
            currentAction = .neutral
        }
    }
    
    private let gamePad = GCController.controllers().first?.microGamepad

    private var currentAction = Action.neutral {
        didSet {
            updateIndicators()
        }
    }
    
     // MARK: Indicators
    private func updateIndicators() {
     
        switch currentAction {
        case .forward:
            self.leftActionIndicator?.image = nil
            self.rightActionIndicator?.image = currentAction.image
            
        case .backward:
            self.leftActionIndicator?.image = currentAction.image
            self.rightActionIndicator?.image = nil
            
        case .neutral:
            self.leftActionIndicator?.image = nil
            self.rightActionIndicator?.image = nil
        }
    }
    
    // MARK: Surface Touch
    private func trackSurfaceTouch() {
        gamePad?.reportsAbsoluteDpadValues = true
        gamePad?.dpad.valueChangedHandler = { (dpad: GCControllerDirectionPad, xValue: Float, yValue: Float) -> Void in
            guard self.isEnabled else {
                return
            }
            
            if xValue > 0.5 {
                self.currentAction = .forward
            } else if xValue < -0.5 {
                self.currentAction = .backward
            } else {
                self.currentAction = .neutral
            }
            self.delegate?.remoteActionPositionControllerDidDetectTouch(self)
            
        }
    }
    
    private func untrackSurfaceTouch() {
        gamePad?.dpad.valueChangedHandler = nil
    }
    
    // MARK: IB Actions
    func click(_ sender: Any) {
        guard isEnabled else {
            return
        }
        self.delegate?.remoteActionPositionController(self, didSelectAction: self.currentAction)
    }
    
    func playOrPause(_ sender: Any) {
        guard isEnabled else {
            return
        }
        
        currentAction = .neutral
        self.delegate?.remoteActionPositionController(self, didSelectAction: self.currentAction)
    }
}

