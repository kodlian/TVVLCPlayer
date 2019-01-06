//
//  Focus View.swift
//  TVVLCPlayer
//
//  Created by Jérémy Marchand on 06/01/2019.
//  Copyright © 2019 Jérémy Marchand. All rights reserved.
//

import UIKit
import CoreGraphics
import GameController

// MARK: - Glowing Focus TabBar
class GlowingFocusTabBar: UITabBar {
    private lazy var focusView: FocusView = {
        FocusView(frame: self.bounds)
    }()
    private lazy var activateFocusViewGesture = TouchGestureRecogniser(target: self, action: #selector(GlowingFocusTabBar.touchesDidOccur))

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        // Display focus only on subview of the taBBar
        if let view = context.nextFocusedView, view.hasSuperview(self) {
            focusView.focusedView = context.nextFocusedView
        } else {
            focusView.focusedView = nil
        }
    }

    @objc private func touchesDidOccur(_ sender: UIGestureRecognizer) {
        switch sender.state {
        case .began:
            focusView.enabled = true
        case .changed, .possible: break
        case .cancelled, .ended, .failed:
            focusView.enabled = false
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addSubview(focusView)
        addGestureRecognizer(activateFocusViewGesture)
    }
}

// MARK: - Focus View
fileprivate final class FocusView: UIView {
    private lazy var focusLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.frame.size.width = 700.0
        layer.frame.origin.x = bounds.midX - layer.frame.size.width / 2.0
        layer.type = .radial
        layer.startPoint = CGPoint(x: 0.5, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 2.0)
        layer.locations = [0.1, 1] as [NSNumber]
        layer.opacity = 0
        return layer
    }()

    var focusedView: UIView? {
        didSet {
            if let view = focusedView {
                let frame = convert(view.bounds, from: view)
                focusLayer.frame.origin.x = frame.midX - focusLayer.frame.width / 2.0
            }
            configure()
        }
    }

    var enabled: Bool = false {
        didSet {
            configure()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true

        // Give focus feedback when touching the surface touch
        let shiftX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        shiftX.minimumRelativeValue = -25
        shiftX.maximumRelativeValue = 25
        addMotionEffect(shiftX)

        layer.addSublayer(focusLayer)
        layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        focusLayer.opacity = enabled && focusedView != nil ? 1 : 0
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let alpha: CGFloat = traitCollection.userInterfaceStyle == .dark ? 0.06 : 0.13
        focusLayer.colors = [UIColor(white: 1.0, alpha: alpha).cgColor,
                             UIColor(white: 1.0, alpha: 0.00).cgColor]
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layer.shadowOpacity = 0
    }
}

private extension UIView {
    func hasSuperview(_ superview: UIView) -> Bool {
        var current = self.superview
        while current != nil {
            if current == superview {
                return true
            }

            current = current?.superview
        }
        return false
    }
}
