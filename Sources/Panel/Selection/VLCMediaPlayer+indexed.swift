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
    var hideDisableTrack: Bool = false

    private var offset: Int {
        return hideDisableTrack ? 1 : 0
    }

    var selectedIndex: Int? {
        set {
            if let selectedIndex = newValue {
                player[keyPath: curentIndexKeyPath] = player[keyPath: indexesKeyPath]?[selectedIndex + offset] as? Int32 ?? 0
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

            return index - offset
        }
    }

    var count: Int {
        guard let count = player[keyPath: indexesKeyPath]?.count else {
            return 0
        }
        return count - offset
    }

    subscript(position: Int) -> String {
        return player[keyPath: namesKeyPath]?[position + offset] as? String ?? "none"
    }
}

extension VLCMediaPlayer {
    var audioTracks: IndexedCollection {
        return IndexedCollection(player: self,
                                 indexesKeyPath: \VLCMediaPlayer.audioTrackIndexes,
                                 namesKeyPath: \VLCMediaPlayer.audioTrackNames,
                                 curentIndexKeyPath: \VLCMediaPlayer.currentAudioTrackIndex,
                                 hideDisableTrack: true)
    }

    var videoSubtitles: IndexedCollection {
        return IndexedCollection(player: self,
                                 indexesKeyPath: \VLCMediaPlayer.videoSubTitlesIndexes,
                                 namesKeyPath: \VLCMediaPlayer.videoSubTitlesNames,
                                 curentIndexKeyPath: \VLCMediaPlayer.currentVideoSubTitleIndex,
                                 hideDisableTrack: false)
    }
}
