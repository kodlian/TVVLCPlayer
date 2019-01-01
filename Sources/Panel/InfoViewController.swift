//
//  InfoViewController.swift
//  TVVLCPlayer
//
//  Created by Jérémy Marchand on 31/12/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import UIKit
import TVVLCKit

class InfoViewController: UIViewController {
    var player: VLCMediaPlayer!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var rightStackView: UIStackView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var qualityImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var artworkWidthConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitle()
        configureCaption()
        configureArtwork()
        configureDescription()
        view.layoutIfNeeded()
        
        // TODO: Find a better way to handle variable height of the info panel
        var height = mainStackView.frame.height
        if artworkImageView.isHidden {
            height = captionLabel.bounds.height + titleLabel.bounds.height + 40
            if !textView.isHidden {
                height += textView.contentSize.height
            }
        } else {
            height = 240
        }
        preferredContentSize = CGSize(width: 1920,
                                      height: height)
    }
    
    func configureArtwork() {
        let mediaDict = player.media?.metaDictionary
        if let image = mediaDict?[VLCMetaInformationArtwork] as? UIImage {
            artworkImageView.image = image
            artworkImageView.isHidden = false
            artworkWidthConstraint.constant = 200 / image.size.height * image.size.width
        } else {
            artworkImageView.isHidden = true
        }
    }

    func configureTitle() {
        let mediaDict = player.media?.metaDictionary
        if let title = mediaDict?[VLCMetaInformationTitle] as? String {
           titleLabel.text = title
        } else {
           titleLabel.text = player.media?.url.absoluteString
        }
        titleLabel.textColor = .gray
    }

    func configureCaption() {
        let media = player.media
        var caption: String = ""
        if let time = media?.length.string {
            caption.append(time)
        }

        captionLabel.text = caption
        captionLabel.textColor = .gray

        if player.videoSize >= CGSize(width: 3840, height: 2160) {
            qualityImageView.image = UIImage(named: "4k")
        } else if player.videoSize >= CGSize(width: 1280, height: 720) {
            qualityImageView.image = UIImage(named: "hd")
        } else {
            qualityImageView.image = nil
        }

    }

    func configureDescription() {
        let mediaDict = player.media.metaDictionary
        let texts = [VLCMetaInformationDescription, VLCMetaInformationCopyright].compactMap { mediaDict[$0] as? String  }

        textView.text = texts.joined(separator: "\n")
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isHidden = texts.isEmpty
        textView.textColor = .gray
    }
}

private func >= (lhs: CGSize, rhs: CGSize) -> Bool {
    return lhs.height >= rhs.height && lhs.width >= rhs.width
}

private extension VLCTime {
    var string: String? {
        guard let rawDuration = value?.doubleValue else {
            return nil
        }

        let duration = rawDuration / 1000
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .brief

        if duration >= 3600 {
            formatter.allowedUnits = [.hour, .minute, .second]
        } else {
            formatter.allowedUnits = [.minute, .second]
        }

        return formatter.string(from: duration) ?? nil
    }
}
