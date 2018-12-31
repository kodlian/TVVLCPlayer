//
//  ConfigurationDataSource.swift
//  TVVLCPlayer
//
//  Created by Jérémy Marchand on 29/12/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import Foundation
import TVVLCKit

protocol SelectableCollection {
    var count: Int { get }
    var selectedIndex: Int? { get set }
    subscript(position: Int) -> String { get }
}
