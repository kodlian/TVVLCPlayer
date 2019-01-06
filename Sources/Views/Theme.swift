//
//  Color.swift
//  TVVLCPlayer
//
//  Created by Jérémy Marchand on 02/01/2019.
//  Copyright © 2019 Jérémy Marchand. All rights reserved.
//

import Foundation

struct DarkTheme {
    static let textColor = UIColor(white: 0.5, alpha: 1.0)
}

struct LightTheme {
    static let textColor = UIColor(white: 0.0, alpha: 0.6)
}

extension UIUserInterfaceStyle {
    var textColor: UIColor {
        if self == .dark {
            return DarkTheme.textColor
        } else {
            return LightTheme.textColor
        }
    }
}
