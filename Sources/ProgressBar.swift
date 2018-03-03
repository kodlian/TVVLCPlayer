//
//  ProgressBar.swift
//  IndexOfTV
//
//  Created by Jérémy Marchand on 26/02/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import UIKit

class ProgressBar: UIView {
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let maskEffectView: UIView = MaskView(frame: CGRect.zero)
    
    class MaskView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            isOpaque = false
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            isOpaque = false
        }
        
        override func draw(_ rect: CGRect) {
            UIColor(white: 1.0, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height/2).fill()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        effectView.mask = maskEffectView
        self.addSubview(effectView)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        effectView.frame = self.bounds
        maskEffectView.frame = self.bounds
    }
 
}
