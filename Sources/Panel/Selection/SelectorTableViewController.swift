//
//  SelectorTableViewController.swift
//  TVVLCPlayer
//
//  Created by Jérémy Marchand on 29/12/2018.
//  Copyright © 2018 Jérémy Marchand. All rights reserved.
//

import UIKit
import TVVLCKit

class SelectorTableViewController: UIViewController {
    var collection: SelectableCollection!
    var emptyText: String!

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var emptyLabel: UILabel!
    @IBOutlet var emptyView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = title?.uppercased()
        emptyLabel.text = emptyText
        tableView.backgroundView = collection.count == 0 ? emptyView : nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToSelectedIndex(animated: false)
    }

    private func scrollToSelectedIndex(animated: Bool = false) {
        if let selectedIndex = collection.selectedIndex {
            tableView.scrollToRow(at: IndexPath(row: selectedIndex, section: 0), at: .middle, animated: animated)
        }
    }
}

// MARK: Data Source
extension SelectorTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SelectableTableViewCell else {
           fatalError()
        }
        cell.label.text = collection[indexPath.row]
        cell.checkmarkView.isHidden = collection.selectedIndex != indexPath.row
        update(cell, with: .gray)
        return cell
    }

    func update(_ cell: SelectableTableViewCell, with color: UIColor) {
        cell.label.textColor = color
        cell.checkmarkView.tintColor = color
    }

    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let indexPath = context.previouslyFocusedIndexPath,
            let cell = tableView.cellForRow(at: indexPath) as? SelectableTableViewCell {
            update(cell, with: .gray)
        }
        if let nextIndexPath = context.nextFocusedIndexPath,
            let cell = tableView.cellForRow(at: nextIndexPath) as? SelectableTableViewCell {
            update(cell, with: .white)
        } else {
            // Reset scroll position when focus leave view
            scrollToSelectedIndex(animated: true)
        }
    }
}

// MARK: Delegate
extension SelectorTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPathsToRefresh = [indexPath]
        if let previousIndex = collection.selectedIndex {
            indexPathsToRefresh.append(IndexPath(row: previousIndex, section: 0))
        }
        collection.selectedIndex = indexPath.row
        tableView.reloadRows(at: indexPathsToRefresh, with: .fade)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
}
