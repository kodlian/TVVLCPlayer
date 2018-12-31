//
//  AudioViewController.swift
//  TVVLCPlayer
//
//  Created by Jérémy Marchand on 29/12/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import UIKit
import TVVLCKit

class AudioViewController: UIViewController {
    var player: VLCMediaPlayer!
    private var equalizerView: UIView!

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [equalizerView]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: Translate title
        // TODO: enum indentifier name
        if let viewController = segue.destination as? SelectorTableViewController {
            if segue.identifier == "track" {
                viewController.collection = player.audioTracks
                viewController.title = "track"
                viewController.emptyText = "No Audio"
                setNeedsFocusUpdate()
            } else if segue.identifier == "equalizer" {
                viewController.collection = player.equalizer
                viewController.title = "sound"
                equalizerView = viewController.view
            } else if segue.identifier == "delay" {
                viewController.collection = player.audioDelay
                viewController.title = "delay"
            }
        }
    }
}
