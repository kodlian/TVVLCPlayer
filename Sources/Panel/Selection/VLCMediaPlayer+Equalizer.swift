//
//  Equalizer.swift
//  TVVLCPlayer
//
//  Created by Jérémy Marchand on 30/12/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import Foundation
import TVVLCKit

struct Equalizer: SelectableCollection {
    enum Profile: UInt32, CaseIterable {
        case fullDynamicRange = 0
        case reduceLoudSounds = 15

        var localizedString: String {
            switch self {
            // TODO: Translate
            case .fullDynamicRange:
                return "Full Dynamic Range"
            case .reduceLoudSounds:
                return "Reduce Loud Sounds"
            }
        }
    }

    let player: VLCMediaPlayer

    var selectedIndex: Int? {
        didSet {
            guard let index = selectedIndex else {
                return
            }
            let current = Profile.allCases[index]
            player.resetEqualizer(fromProfile: current.rawValue)
            player.equalizerEnabled = current == .reduceLoudSounds
        }
    }

    var count: Int {
        return 2
    }

    subscript(position: Int) -> String {
        return Profile.allCases[position].localizedString
    }

    init(player: VLCMediaPlayer) {
        self.player = player
        let currentProfile: Profile = player.equalizerEnabled ? .reduceLoudSounds: .fullDynamicRange
        selectedIndex = Profile.allCases.firstIndex(of: currentProfile)
    }
}

extension VLCMediaPlayer {
    var equalizer: Equalizer {
        return Equalizer(player: self)
    }
}
