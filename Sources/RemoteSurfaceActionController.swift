//
//  SiriRemoteSurfaceController.swift
//  Pods-Demo
//
//  Created by Jérémy Marchand on 03/03/2018.
//

import Foundation
import GameController

class RemoteSurfaceActionController {
    let gamePad = GCController.controllers().first!.microGamepad!
    var currentAction = Action.show
    enum Action {
        case forward, backward, show
        
        var image: UIImage? {
            let bundle = Bundle(identifier: "org.cocoapods.TVVLCPlayer")
            
            switch self {
            case .forward:
                
                return UIImage(named:  "SkipForward30", in: bundle, compatibleWith: nil)

            case .backward:
                return UIImage(named: "SkipBack30", in: bundle, compatibleWith: nil)

            case .show:
                return nil
                
            }
        }
    }
    
    init(actionHandler: @escaping (Action) -> Void) {
        gamePad.reportsAbsoluteDpadValues = true
        gamePad.dpad.valueChangedHandler = { (dpad: GCControllerDirectionPad, xValue: Float, yValue: Float) -> Void in
            // … write your logic here
            // In our case, we just needed to detect whether the touch    position was on the left or
            // right, we can just use the left and right property of the GCControllerDirectionPad
            
                if xValue > 0.5 {
                    self.currentAction = .forward
                } else if xValue < -0.5 {
                    self.currentAction = .backward
                } else {
                    self.currentAction = .show
                }
       
            
            actionHandler(self.currentAction)

            
            
        }
    }
}
