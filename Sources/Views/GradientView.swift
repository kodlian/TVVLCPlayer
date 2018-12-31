//
//  GradientView.swift
//  IndexOfTV
//
//  Created by Jérémy Marchand on 26/02/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import UIKit

class GradientView: UIView {
    @IBInspectable
    var topColor: UIColor = .clear
    @IBInspectable
    var bottomColor: UIColor = .black

    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        (layer as? CAGradientLayer)?.colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
