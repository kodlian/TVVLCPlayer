//
//  SubtitlesViewController.swift
//  TVVLCPlayer
//
//  Created by Jérémy Marchand on 29/12/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import UIKit
import TVVLCKit

class SubtitlesViewController: UIViewController {
    var player: VLCMediaPlayer!
    private var trackView: UIView!

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return player.videoSubTitlesIndexes.isEmpty ? super.preferredFocusEnvironments : [trackView]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: Translate title
        // TODO: enum indentifier name
        if let viewController = segue.destination as? SelectorTableViewController {
            if segue.identifier == "list" {
                viewController.collection = player.videoSubtitles
                viewController.title = "track"
                viewController.emptyText = "No Subtitles"
                trackView = viewController.view

            } else if segue.identifier == "delay" {
                viewController.collection = player.videoSubtitlesDelay
                viewController.title = "delay"
            }
        }
    }
}
