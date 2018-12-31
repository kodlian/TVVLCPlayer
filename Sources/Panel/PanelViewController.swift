//
//  PanelViewController.swift
//  TVVLCPlayer
//
//  Created by Jérémy Marchand on 29/12/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import UIKit
import TVVLCKit

protocol PanelViewControllerDelegate: class {
    func panelViewControllerDidDismiss(_ panelViewController: PanelViewController)
}

// MARK: - PanelViewController
class PanelViewController: UIViewController {
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var contentView: UIView!
    weak var delegate: PanelViewControllerDelegate?
    var player: VLCMediaPlayer!
    var selectedIndex: Int = 0 {
        didSet {
            guard oldValue != selectedIndex else {
                return
            }
            updateContentForSelection()
        }
    }

    private var currentViewController: UIViewController?
    private var viewControllers: [UIViewController] = [] {
        didSet {
            updateTabBars()
        }
    }

    private lazy var focusEnvironments: [UIFocusEnvironment] = [self.tabBar]
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return focusEnvironments
    }

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: 1920, height: 480)
        setupViewControllers()
        updateContentForSelection()
    }

    func setupViewControllers() {
        // TODO: Translate title
        // swiftlint:disable force_cast
        let audioViewController = storyboard!.instantiateViewController(withIdentifier: "audio") as! AudioViewController
        audioViewController.title = "Audio"
        audioViewController.player = player
        // swiftlint:disable force_cast line_length
        let subtitlesViewController = storyboard!.instantiateViewController(withIdentifier: "subtitles") as! SubtitlesViewController
        subtitlesViewController.title = "Subtitles"
        subtitlesViewController.player = player

        viewControllers = [audioViewController, subtitlesViewController]
    }

    func updateTabBars() {
        guard viewIfLoaded != nil else {
            return
        }
        let items = viewControllers.enumerated().map { UITabBarItem(title: $1.title, image: nil, tag: $0) }
        tabBar.items = items
        tabBar.selectedItem = items[selectedIndex]
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextView = context.nextFocusedView {
            tabBar.tintColor = nextView.hasSuperview(tabBar) ? .white : .gray
        }
    }

    // MARK: Actions
    @IBAction func collapse(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.panelViewControllerDidDismiss(self)
        }
    }

    @IBAction func focusOnTabBar(_ sender: Any) {
        focusEnvironments = [tabBar]
        setNeedsFocusUpdate()
    }

    @IBAction func focusOnContentView(_ sender: Any) {
        if let currentViewController = currentViewController {
            focusEnvironments = currentViewController.preferredFocusEnvironments
        } else {
            focusEnvironments = []
        }
        setNeedsFocusUpdate()
    }

    private func updateContentForSelection() {
        guard viewIfLoaded != nil else {
            return
        }
        let newViewController = viewControllers[selectedIndex]
        addChild(newViewController)

        if let oldViewController = currentViewController {
            newViewController.view.alpha = 0
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false

            contentView.addSubview(newViewController.view)
            newViewController.view.constraintEdgeToSuperView()

            UIView.animate(withDuration: 0.3,
                           animations: {
                           oldViewController.view.alpha = 0
                           newViewController.view.alpha = 1

            },
                           completion: { (_) in
                            oldViewController.removeFromParent()
                            oldViewController.view.alpha = 1
                            oldViewController.view.removeFromSuperview()
            })
        } else {
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(newViewController.view)
            newViewController.view.constraintEdgeToSuperView()
        }
        currentViewController = newViewController
    }
}

// MARK: - TabBar delegate
extension PanelViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selectedIndex = item.tag
    }
}

// MARK: - UIView extension
extension UIView {
    func constraintEdgeToSuperView() {
        guard let superview = self.superview else {
            return
        }

        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true

    }

    func hasSuperview(_ superview: UIView) -> Bool {
        var current = self.superview
        while current != nil {
            if current == superview {
                return true
            }

            current = current?.superview
        }
        return false
    }
}
