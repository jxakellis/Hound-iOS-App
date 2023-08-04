//
//  DropDownUIView.swift
//  DropDownUIView
//
//  Created by ems on 02/05/19.
//  Copyright © 2019 Majesco. All rights reserved.
//

import UIKit

protocol DropDownUIViewDataSource {
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String)
    /// Returns number of rows in a given section of the dropDownMenu
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int
    /// Returns number section in the dropDownMenu
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int

    /// Called when an item is selected in the dropdown menu
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String)
}

final class DropDownUIView: GeneralUIView {

    // MARK: - Static

    /// Leading and trailing inset for labels inside drop down. 8.0 aligns properly with the inset from a  GeneralUILabel
    static let insetForGeneralUILabel: CGFloat = 8.0
    /// Leading and trailing inset for labels inside drop down.
    static let insetForLogFilter: CGFloat = 12.0

    /// Height of each row in the dropdownuiview, should be same height as the GeneralUIlabel that it presents on
    static let rowHeightForGeneralUILabel: CGFloat = 45.0

    // MARK: - Variables

    /// The DropDownIdentifier is to differentiate if you are using multiple Xibs
    private var dropDownUIViewIdentifier: String = "DROP_DOWN"
    /// Reuse Identifier of your custom cell
    private var cellReusableIdentifier: String = "DROP_DOWN_CELL"
    // Table View
    private(set) var dropDownTableView: GeneralUITableView?
    private var dropDownViewWidth: CGFloat = 0
    private var dropDownViewOffset: CGFloat = 0
    private var dropDownDataSource: DropDownUIViewDataSource?

    // Other Variables
    private var viewPositionReference: CGRect?
    private(set) var isDown: Bool = false

    // MARK: - DropDown Methods

    /// Make Table View Programatically
    func setupDropDown(forDropDownUIViewIdentifier: String = "DropDownView", forCellReusableIdentifier: String = "DropDownTableViewCell", forDataSource: DropDownUIViewDataSource, forNibName: String = "DropDownTableViewCell", forViewPositionReference: CGRect, forOffset: CGFloat, forRowHeight: CGFloat) {
        self.dropDownUIViewIdentifier = forDropDownUIViewIdentifier
        self.cellReusableIdentifier = forCellReusableIdentifier
        self.dropDownDataSource = forDataSource
        self.viewPositionReference = forViewPositionReference
        self.dropDownViewWidth = forViewPositionReference.width
        self.dropDownViewOffset = forOffset

        // The shadow on self so it can expand as much as it wants, border on dropDownTableView so it and the subviews can be masked / clipped.
        self.shadowColor = UIColor.label
        self.shadowOffset = CGSize(width: 0, height: 2.5)
        self.shadowRadius = 5.0
        self.shadowOpacity = 0.5

        self.frame = CGRect(x: forViewPositionReference.minX, y: forViewPositionReference.maxY + forOffset, width: 0, height: 0)

        let dropDownTableView = GeneralUITableView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: 0, height: 0))
        self.dropDownTableView = dropDownTableView

        // Sets Row Height of your Custom XIB
        dropDownTableView.rowHeight = forRowHeight
        dropDownTableView.estimatedRowHeight = forRowHeight
        dropDownTableView.register(UINib(nibName: forNibName, bundle: nil), forCellReuseIdentifier: self.cellReusableIdentifier)

        // The shadow on self so it can expand as much as it wants, border on dropDownTableView so it and the subviews can be masked / clipped.
        dropDownTableView.shouldRoundCorners = true
        dropDownTableView.borderColor = .systemGray2
        dropDownTableView.borderWidth = 0.5

        dropDownTableView.showsVerticalScrollIndicator = false
        dropDownTableView.showsHorizontalScrollIndicator = false
        dropDownTableView.separatorStyle = .none
        dropDownTableView.delegate = self
        dropDownTableView.dataSource = self
        dropDownTableView.allowsSelection = true
        dropDownTableView.isUserInteractionEnabled = true

        self.addSubview(dropDownTableView)
    }

    /// Shows Drop Down Menu, hides it if already present. The height of the dropdown shown will be equal to the rowHeight of the individual dropdown cells multiplied by the numberOfRowsToShow
    func showDropDown(numberOfRowsToShow numRows: CGFloat, animated: Bool) {
        guard isDown == false else {
            self.hideDropDown()
            return
        }

        guard let dropDownTableView = dropDownTableView, let viewPositionReference = viewPositionReference else {
            return
        }

        let height = numRows * dropDownTableView.rowHeight
        self.dropDownTableView?.reloadData()

        isDown = true
        self.frame = CGRect(x: viewPositionReference.minX, y: viewPositionReference.maxY + dropDownViewOffset, width: dropDownViewWidth, height: 0)
        dropDownTableView.frame = CGRect(x: 0, y: 0, width: dropDownViewWidth, height: 0)

        UIView.animate(withDuration: animated ? 0.7 : 0.0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear, animations: {
            self.frame.size = CGSize(width: self.dropDownViewWidth, height: height)
            dropDownTableView.frame.size = CGSize(width: self.dropDownViewWidth, height: height)
        })

    }

    /// Hides DropDownMenu
    func hideDropDown(removeFromSuperview shouldRemoveFromSuperview: Bool = false) {
        guard isDown else {
            return
        }

        isDown = false

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveLinear, animations: {
            self.frame.size = CGSize(width: self.dropDownViewWidth, height: 0)
            self.dropDownTableView?.frame.size = CGSize(width: self.dropDownViewWidth, height: 0)
        }, completion: { _ in
            if shouldRemoveFromSuperview == true {
                self.removeFromSuperview()
                self.dropDownTableView?.removeFromSuperview()
            }

        })
    }
}

// MARK: - Table View Methods

extension DropDownUIView: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        (dropDownDataSource?.numberOfSections(dropDownUIViewIdentifier: self.dropDownUIViewIdentifier) ?? 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (dropDownDataSource?.numberOfRows(forSection: section, dropDownUIViewIdentifier: self.dropDownUIViewIdentifier) ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = (dropDownTableView?.dequeueReusableCell(withIdentifier: self.cellReusableIdentifier) ?? UITableViewCell())

        dropDownDataSource?.setupCellForDropDown(cell: cell, indexPath: indexPath, dropDownUIViewIdentifier: self.dropDownUIViewIdentifier)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dropDownDataSource?.selectItemInDropDown(indexPath: indexPath, dropDownUIViewIdentifier: self.dropDownUIViewIdentifier)
    }

}
