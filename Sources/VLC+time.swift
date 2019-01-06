//
//  VLC+addition.swift
//  IndexOfTV
//
//  Created by Jérémy Marchand on 26/02/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import Foundation
import TVVLCKit

extension VLCMediaPlayer {
    var totalTime: VLCTime? {
        return time - remainingTime
    }
}

func - (timeLeft: VLCTime, timeRight: VLCTime) -> VLCTime {
    guard let left = timeLeft.value?.doubleValue, let right = timeRight.value?.doubleValue else {
        return VLCTime()
    }
    return VLCTime(number: (left - right) as NSNumber)
}
func + (timeLeft: VLCTime, timeRight: VLCTime) -> VLCTime {
    guard let left = timeLeft.value?.doubleValue, let right = timeRight.value?.doubleValue else {
        return VLCTime()
    }
    return VLCTime(number: (left + right) as NSNumber)
}
func * (timeLeft: VLCTime, factor: Double) -> VLCTime {
    guard let left = timeLeft.value?.doubleValue else {
        return VLCTime()
    }
    return VLCTime(number: (left * factor) as NSNumber)
}

extension VLCTime {
    public convenience init(_ double: Double) {
        self.init(number: double as NSNumber)
    }
}
