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
    func panelViewController(_ panelViewController: PanelViewController, didSelectTabAtIndex: Int)
    func panelViewControllerDidDismiss(_ panelViewController: PanelViewController)
}

// MARK: - PanelViewController
class PanelViewController: UIViewController {
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!

    weak var delegate: PanelViewControllerDelegate?
    var player: VLCMediaPlayer!
    var selectedIndex: Int = 0 {
        didSet {
            guard oldValue != selectedIndex else {
                return
            }
            updateContentForSelection()
            self.delegate?.panelViewController(self, didSelectTabAtIndex: selectedIndex)
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
        setupViewControllers()
        updateContentForSelection()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Hack to put a continous blur background behind the panel
        // Hide the background bar of the tabBar and extend the background tabBar behind.
        // This is done here since the background of tabBar is only available after the view has appeared.
        tabBar.subviews[0].isHidden = true
        backgroundTopConstraint.constant = -tabBar.frame.height
    }

    func setupViewControllers() {
        // TODO: Translate title
        // swiftlint:disable force_cast
        let infoViewController = storyboard!.instantiateViewController(withIdentifier: "info") as! InfoViewController
        infoViewController.title = "Info"
        infoViewController.player = player

        // swiftlint:disable force_cast line_length
        let subtitlesViewController = storyboard!.instantiateViewController(withIdentifier: "subtitles") as! SubtitlesViewController
        subtitlesViewController.title = "Subtitles"
        subtitlesViewController.player = player

        // swiftlint:disable force_cast
        let audioViewController = storyboard!.instantiateViewController(withIdentifier: "audio") as! AudioViewController
        audioViewController.title = "Audio"
        audioViewController.player = player
        viewControllers = [infoViewController, subtitlesViewController, audioViewController]

        contentView.layer.masksToBounds = true // Avoid content to appear on tabbar during panel content transition and height animation

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
            tabBar.tintColor = nextView.hasSuperview(tabBar) ? .white : traitCollection.userInterfaceStyle.textColor
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
            newViewController.view.constraintToSuperviewBottom(usingHeight: newViewController.preferredContentSize.height)
            self.view.layoutIfNeeded() // Force layout the previous constraints to avoid them to animate

            self.contentHeightConstraint.constant = newViewController.preferredContentSize.height

            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                            oldViewController.view.alpha = 0
                            newViewController.view.alpha = 1

                            self.view.layoutIfNeeded() // Animate height constraint

            },
                           completion: { (_) in
                            oldViewController.removeFromParent()
                            oldViewController.view.removeFromSuperview()
                            oldViewController.view.alpha = 1

            })
        } else {
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(newViewController.view)
            newViewController.view.constraintToSuperviewBottom(usingHeight: newViewController.preferredContentSize.height)
            newViewController.view.layoutIfNeeded()
            self.contentHeightConstraint.constant = newViewController.preferredContentSize.height

        }

        currentViewController = newViewController
        preferredContentSize = CGSize(width: 1920, height: newViewController.preferredContentSize.height + tabBar
            .frame.height)
    }
}

// MARK: - TabBar delegate
extension PanelViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selectedIndex = item.tag
    }
}

// MARK: - UIView extension
private extension UIView {
    func constraintToSuperviewBottom(usingHeight height: CGFloat) {
        guard let superview = self.superview else {
            return
        }
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
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
