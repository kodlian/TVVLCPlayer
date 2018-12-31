//
//  VLCMediaPlayer+indexed.swift
//  TVVLCPlayer
//
//  Created by Jérémy Marchand on 30/12/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import Foundation
import TVVLCKit

/// Indexed
struct IndexedCollection: SelectableCollection {
    let player: VLCMediaPlayer
    let indexesKeyPath: KeyPath<VLCMediaPlayer, [Any]?>
    let namesKeyPath: KeyPath<VLCMediaPlayer, [Any]?>
    let curentIndexKeyPath: ReferenceWritableKeyPath<VLCMediaPlayer, Int32>

    var selectedIndex: Int? {
        set {
            if let selectedIndex = newValue {
                player[keyPath: curentIndexKeyPath] = player[keyPath: indexesKeyPath]?[selectedIndex] as? Int32 ?? 0
            } else {
                player[keyPath: curentIndexKeyPath] = -1
            }
        }
        get {
            guard let audioTrackIndexes = player[keyPath: indexesKeyPath] as? [Int32],
                let index = audioTrackIndexes.firstIndex(where: { index in
                    return index == player[keyPath: curentIndexKeyPath]
                }) else {
                    return nil
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
