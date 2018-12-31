//
//  Delay.swift
//  TVVLCPlayer
//
//  Created by Jérémy Marchand on 30/12/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import Foundation
import TVVLCKit

/// Delay
struct DelayCollection: SelectableCollection {
    static let factor = 1000000
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.positivePrefix = formatter.plusSign
        return formatter
    }()

    let delay = [Int](-60...60)
    let player: VLCMediaPlayer
    let keyPath: ReferenceWritableKeyPath<VLCMediaPlayer, Int>

    var selectedIndex: Int? = 60 {
        didSet {
            if let selectedIndex = selectedIndex {
                player[keyPath: keyPath] = delay[selectedIndex] * DelayCollection.factor
            } else {
                player[keyPath: keyPath] = 0
            }
        }
    }

    var count: Int {
        return delay.count
    }

    subscript(position: Int) -> String {
        let delay = self.delay[position]
        if delay == 0 {
            return "0"
        } else {
            return numberFormatter.string(from: delay as NSNumber) ?? ""
        }
    }

    init(player: VLCMediaPlayer, keyPath: ReferenceWritableKeyPath<VLCMediaPlayer, Int>) {
        self.player = player
        self.keyPath = keyPath
        let currentDelay = player[keyPath: keyPath] / DelayCollection.factor
        selectedIndex = delay.firstIndex { $0 == currentDelay }
    }
}

extension VLCMediaPlayer {
    var audioDelay: DelayCollection {
        return DelayCollection(player: self, keyPath: \VLCMediaPlayer.currentAudioPlaybackDelay)
    }

    var videoSubtitlesDelay: DelayCollection {
        return DelayCollection(player: self, keyPath: \VLCMediaPlayer.currentVideoSubTitleDelay)
    }
}
