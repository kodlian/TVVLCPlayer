//
//  TouchGestureRecogniser.swift
//  TVVLCPlayer
//
//  Created by Jérémy Marchand on 06/01/2019.
//  Copyright © 2019 Jérémy Marchand. All rights reserved.
//

import UIKit

class TouchGestureRecogniser: UIGestureRecognizer {
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        cancelsTouchesInView = true
    }

    override func awakeFromNib() {
        allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        cancelsTouchesInView = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .began
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .ended
    }
    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
