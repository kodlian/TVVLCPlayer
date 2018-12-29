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
    var selectedIndex: Int { get set }
    subscript(position: Int) -> String { get }
}

/// Track
struct IndexedCollection: SelectableCollection {
    let player: VLCMediaPlayer
    let indexesKeyPath: KeyPath<VLCMediaPlayer, [Any]?>
    let namesKeyPath: KeyPath<VLCMediaPlayer, [Any]?>
    let curentIndexKeyPath: ReferenceWritableKeyPath<VLCMediaPlayer, Int32>

    var selectedIndex: Int {
        set {
           player[keyPath: curentIndexKeyPath] = player[keyPath: indexesKeyPath]?[selectedIndex] as? Int32 ?? 0
        }
        get {
            guard let audioTrackIndexes = player[keyPath: indexesKeyPath] as? [Int32],
                let index = audioTrackIndexes.firstIndex(where: { index in
                    return index == player[keyPath: curentIndexKeyPath]
                }) else {
                    fatalError()
            }

            return index
        }
    }

    var count: Int {
        return player[keyPath: indexesKeyPath]?.count ?? 0
    }

    subscript(position: Int) -> String {
        return player[keyPath: namesKeyPath]?[position] as? String ?? "none"
    }
}

extension VLCMediaPlayer {
    var audioTracks: IndexedCollection {
        return IndexedCollection(player: self,
                               indexesKeyPath: \VLCMediaPlayer.audioTrackIndexes,
                               namesKeyPath: \VLCMediaPlayer.audioTrackNames,
                               curentIndexKeyPath: \VLCMediaPlayer.currentAudioTrackIndex)
    }

    var videoSubtitles: IndexedCollection {
        return IndexedCollection(player: self,
                               indexesKeyPath: \VLCMediaPlayer.videoSubTitlesIndexes,
                               namesKeyPath: \VLCMediaPlayer.videoSubTitlesNames,
                               curentIndexKeyPath: \VLCMediaPlayer.currentVideoSubTitleIndex)
    }
}

/// Delay
struct DelayCollection: SelectableCollection {
    let delay = [Int](-60...60)
    let player: VLCMediaPlayer
    let keyPath: ReferenceWritableKeyPath<VLCMediaPlayer, Int>

    var selectedIndex: Int = 0 {
        didSet {
            player[keyPath: keyPath] = delay[selectedIndex]
        }
    }

    var count: Int {
        return delay.count
    }

    subscript(position: Int) -> String {
        return String(delay[position])
    }
}

extension VLCMediaPlayer {
    var audioDelay: DelayCollection {
        return DelayCollection(player: self, keyPath: \VLCMediaPlayer.currentAudioPlaybackDelay, selectedIndex: 0)
    }

    var videoSubtitlesDelay: DelayCollection {
        return DelayCollection(player: self, keyPath: \VLCMediaPlayer.currentVideoSubTitleDelay, selectedIndex: 0)
    }
}
