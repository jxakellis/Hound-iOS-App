//
//  HoundDropDown.swift
//  HoundDropDown
//
//  Created by ems on 02/05/19.
//  Copyright © 2019 Majesco. All rights reserved.
//

import UIKit

protocol HoundDropDownDataSource {
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, identifier: any HoundDropDownType)
    /// Returns number of rows in a given section of the dropDownMenu
    func numberOfRows(forSection: Int, identifier: any HoundDropDownType) -> Int
    /// Returns number section in the dropDownMenu
    func numberOfSections(identifier: any HoundDropDownType) -> Int

    /// Called when an item is selected in the dropdown menu
    func selectItemInDropDown(indexPath: IndexPath, identifier: any HoundDropDownType)
}

final class HoundDropDown<T: HoundDropDownType>: HoundView, UITableViewDelegate, UITableViewDataSource {
    typealias Identifier = T
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let identifier = identifier else {
            return 0
        }
        
        return (dropDownDataSource?.numberOfSections(identifier: identifier) ?? 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let identifier = identifier else {
            return 0
        }
        
        return (dropDownDataSource?.numberOfRows(forSection: section, identifier: identifier) ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let identifier = identifier else {
            return HoundTableViewCell()
        }
        
        let cell: UITableViewCell = (dropDownTableView?.dequeueReusableCell(withIdentifier: HoundDropDownTVC.reuseIdentifier) ?? HoundTableViewCell())

        dropDownDataSource?.setupCellForDropDown(cell: cell, indexPath: indexPath, identifier: identifier)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let identifier = identifier else {
            return
        }
        
        dropDownDataSource?.selectItemInDropDown(indexPath: indexPath, identifier: identifier)
    }
    
    // MARK: - Properties

    /// The DropDownIdentifier is to differentiate if you are using multiple Xibs
    private var identifier: Identifier?
    // Table View
    private(set) var dropDownTableView: HoundTableView?
    private var dropDownViewWidth: CGFloat = 0
    private var dropDownViewOffset: CGFloat = 0
    private var dropDownDataSource: HoundDropDownDataSource?

    // Other Variables
    private var viewPositionReference: CGRect?
    private(set) var isDown: Bool = false

    // MARK: - DropDown Methods

    /// Make Table View Programatically
    func setupDropDown(identifier: Identifier, dataSource: HoundDropDownDataSource, viewPositionReference: CGRect, offset: CGFloat = Constant.Constraint.Spacing.contentTightIntraVert) {
        self.identifier = identifier
        self.dropDownDataSource = dataSource
        self.viewPositionReference = viewPositionReference
        self.dropDownViewWidth = viewPositionReference.width
        self.dropDownViewOffset = offset

        // The shadow on self so it can expand as much as it wants, border on dropDownTableView so it and the subviews can be masked / clipped.
        self.shadowColor = UIColor.label
        self.shadowOffset = CGSize(width: 0, height: 2.5)
        self.shadowRadius = 5.0
        self.shadowOpacity = 0.5

        self.frame = CGRect(x: viewPositionReference.minX, y: viewPositionReference.maxY + offset, width: 0, height: 0)

        let dropDownTableView = HoundTableView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: 0, height: 0))
        self.dropDownTableView = dropDownTableView

        dropDownTableView.register(HoundDropDownTVC.self, forCellReuseIdentifier: HoundDropDownTVC.reuseIdentifier)

        // The shadow on self so it can expand as much as it wants, border on dropDownTableView so it and the subviews can be masked / clipped.
        dropDownTableView.applyStyle(.thinGrayBorder)

        dropDownTableView.delegate = self
        dropDownTableView.dataSource = self

        self.addSubview(dropDownTableView)
    }

    /// Shows Drop Down Menu, hides it if already present. The height of the dropdown shown will be equal to the rowHeight of the individual dropdown cells multiplied by the numberOfRowsToShow
    func showDropDown(numberOfRowsToShow numberOfRows: CGFloat, animated: Bool) {
        guard let identifier = identifier else {
            return
        }
        
        guard isDown == false else {
            self.hideDropDown(animated: animated)
            return
        }

        guard let dropDownTableView = dropDownTableView, let viewPositionReference = viewPositionReference else { return }

        let heightSpecifiedForNumberOfRows = numberOfRows * dropDownTableView.rowHeight
        let heightNeededToDisplayAllRows: CGFloat = {
            var heightNeeded: CGFloat = 0.0
            let numberOfSections = dropDownDataSource?.numberOfSections(identifier: identifier) ?? 0
            
            for i in 0..<numberOfSections {
                let numberOfRows = dropDownDataSource?.numberOfRows(forSection: i, identifier: identifier) ?? 0
                heightNeeded += CGFloat(numberOfRows) * dropDownTableView.rowHeight
            }
            
            return heightNeeded
        }()
        
        self.dropDownTableView?.isScrollEnabled = heightNeededToDisplayAllRows > heightSpecifiedForNumberOfRows
        
        self.dropDownTableView?.reloadData()
        
        isDown = true
        self.frame = CGRect(x: viewPositionReference.minX, y: viewPositionReference.maxY + dropDownViewOffset, width: dropDownViewWidth, height: 0)
        dropDownTableView.frame = CGRect(x: 0, y: 0, width: dropDownViewWidth, height: 0)
        
        // The shadow takes up a certain amount of space, in addition to the size of the dropdown view, so distance to bottom should account for that.
        let distanceToBottomExtraPadForShadow = max((self.shadowRadius ?? 0.0) + (self.shadowOffset?.height ?? 0.0), 0.0)
        // Distance to the bottom of the the superview from the top of our view.
        // This, in essence, is the amount if displayable space we have to work with. Any more than this, and we are trying to display outside the superview.
        let distanceToBottom = max((self.superview?.frame.height ?? 0.0) - self.frame.minY - distanceToBottomExtraPadForShadow, 0.0)
        // First, we don't want to make the drop down larger than the space needed to display all of its content. So we limit its size to the theoretical maximum space it would need to display all of its content
        // Second, we don't want the drop down larger than the available space in the superview. So we cap its size at the distance from the top of the dropDownView to the bottom of the superview.
        let height = min(min(heightSpecifiedForNumberOfRows, heightNeededToDisplayAllRows), distanceToBottom)

        UIView.animate(withDuration: animated ? 0.7 : 0.0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear, animations: {
            self.frame.size = CGSize(width: self.dropDownViewWidth, height: height)
            dropDownTableView.frame.size = CGSize(width: self.dropDownViewWidth, height: height)
        })

    }

    /// Hides DropDownMenu
    func hideDropDown(animated: Bool) {
        guard isDown else { return }

        isDown = false

        UIView.animate(withDuration: animated ? 0.5 : 0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveLinear, animations: {
            self.frame.size = CGSize(width: self.dropDownViewWidth, height: 0)
            self.dropDownTableView?.frame.size = CGSize(width: self.dropDownViewWidth, height: 0)
        })
    }
}
