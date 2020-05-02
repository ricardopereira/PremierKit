//
//  PremierStaticTableView.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 01/05/2020.
//  Copyright © 2020 Ricardo Pereira. All rights reserved.
//

import UIKit

public enum StaticTableViewSelectionType {
    case none
    case tap
    case single
    case multi
}

public protocol StaticTableItem: Hashable {
    var description: String { get }
}

open class StaticTableView<T: StaticTableItem>: UITableView, UITableViewDelegate, UITableViewDataSource {

    public let headerTitle: String
    public let items: [T]
    public let selectionType: StaticTableViewSelectionType

    public var allowDeselection: Bool = true

    /**
     The total of items that can be selected.
     If it's `0` then there's no limit.
     */
    public var maxNumberOfSelections: Int = 0

    public var selectedRows = [Int]() {
        didSet {
            onDidSelectionChanged?()
        }
    }

    public var selectedItems: [T] {
        get {
            return selectedRows.compactMap({ items.at($0) })
        }
        set {
            selectedRows = newValue.compactMap({ items.firstIndex(of: $0) })
        }
    }

    public var onDidSelectionChanged: (() -> Void)?

    public init(title: String, items: [T], selectionType: StaticTableViewSelectionType) {
        self.headerTitle = title
        self.items = items
        self.selectionType = selectionType
        if #available(iOS 13.0, *) {
            super.init(frame: .zero, style: .insetGrouped)
        }
        else {
            super.init(frame: .zero, style: .grouped)
        }
        self.delegate = self
        self.dataSource = self
    }

    @available(iOS, unavailable)
    override public init(frame: CGRect, style: UITableView.Style) {
        self.headerTitle = ""
        self.items = [T]()
        self.selectionType = .none
        super.init(frame: frame, style: style)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none

        if 0..<items.count ~= indexPath.row {
            cell.textLabel?.text = items[indexPath.row].description
        }
        else {
            cell.textLabel?.text = "<empty>"
        }

        if selectedRows.firstIndex(of: indexPath.row) == nil {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectionType {
        case .none:
            tableView.deselectRow(at: indexPath, animated: true)
        case .single:
            if selectedRows.firstIndex(of: indexPath.row) == nil {
                selectedRows = [indexPath.row]
            }
            else if allowDeselection {
                selectedRows = []
            }
            tableView.reloadData()
        case .multi:
            if let selectedIndex = selectedRows.firstIndex(of: indexPath.row) {
                selectedRows.remove(at: selectedIndex)
            }
            else if maxNumberOfSelections <= 0 || selectedRows.count < maxNumberOfSelections {
                selectedRows.append(indexPath.row)
            }
            tableView.reloadData()
        case .tap:
            break
        }
    }

}
