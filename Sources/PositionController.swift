//
//  PositionController.swift
//  Pods-Demo
//
//  Created by Jérémy Marchand on 04/03/2018.
//

import Foundation

protocol PositionController: class {
    var isEnabled: Bool { get set }
    
    func click(_ sender: Any)
    func playOrPause(_ sender: Any)
}
