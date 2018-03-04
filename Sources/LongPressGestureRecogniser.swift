

import Foundation
import UIKit.UIGestureRecognizerSubclass

class LongPressGestureRecogniser: UIGestureRecognizer {
    var isLongPress: Bool = false
    var isClick: Bool = false

    private var longPressTimer: Timer?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue)]
        cancelsTouchesInView = false

    }
    
    override func awakeFromNib() {
        allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue)]
        cancelsTouchesInView = false
    }
    
    override func reset() {
        longPressTimer?.invalidate()
        longPressTimer = nil
        self.isLongPress = false
        self.isClick = false
        super.reset()
    }

    // MARK: Presses
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        guard let type = presses.first?.type, allowedPressTypes.contains(NSNumber(value: type.rawValue)) else { return }
        state = .began
        self.isClick = true

        longPressTimer?.invalidate()
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            guard self.isClick else {
                return
            }
            print("long press")
            self.isLongPress = true
            self.state = .changed
        }
    }
    
    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent) {

    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        longPressTimer?.invalidate()
        state = .cancelled
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        longPressTimer?.invalidate()
        state = .ended
    }
}

