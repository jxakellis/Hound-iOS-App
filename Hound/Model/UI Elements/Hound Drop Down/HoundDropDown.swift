//
//  HoundDropDown.swift
//  HoundDropDown
//
//  Created by ems on 02/05/19.
//  Copyright © 2019 Majesco. All rights reserved.
//

import UIKit

enum HoundDropDownDirection {
    case down
    case up
}

protocol HoundDropDownDataSource {
    func setupCellForDropDown(cell: HoundDropDownTVC, indexPath: IndexPath, identifier: any HoundDropDownType)
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
            return HoundDropDownTVC()
        }
        
        let cell: HoundDropDownTVC = (dropDownTableView?.dequeueReusableCell(withIdentifier: HoundDropDownTVC.reuseIdentifier) as? HoundDropDownTVC ?? HoundDropDownTVC())
        
        let rows = dropDownDataSource?.numberOfRows(forSection: indexPath.section, identifier: identifier) ?? 0
        let adjustedIndexPath = direction == .up ? IndexPath(row: rows - 1 - indexPath.row, section: indexPath.section) : indexPath
        
        dropDownDataSource?.setupCellForDropDown(cell: cell, indexPath: adjustedIndexPath, identifier: identifier)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let identifier = identifier else {
            return
        }
        
        HapticsManager.selectionChanged()
        
        let rows = dropDownDataSource?.numberOfRows(forSection: indexPath.section, identifier: identifier) ?? 0
        let adjustedIndexPath = direction == .up ? IndexPath(row: rows - 1 - indexPath.row, section: indexPath.section) : indexPath
        
        dropDownDataSource?.selectItemInDropDown(indexPath: adjustedIndexPath, identifier: identifier)
    }
    
    // MARK: - Properties
    
    /// The DropDownIdentifier is to differentiate if you are using multiple Xibs
    private var identifier: Identifier?
    // Table View
    private(set) var dropDownTableView: HoundTableView?
    private var dropDownViewWidth: CGFloat = 0
    private var dropDownViewOffset: CGFloat = 0
    private var dropDownDataSource: HoundDropDownDataSource?
    private var direction: HoundDropDownDirection = .down
    
    // Other Variables
    private var viewPositionReference: CGRect?
    private(set) var isDown: Bool = false
    
    // MARK: - DropDown Methods
    
    /// Make Table View Programatically
    func setupDropDown(
        identifier: Identifier,
        dataSource: HoundDropDownDataSource,
        viewPositionReference: CGRect,
        offset: CGFloat = Constant.Constraint.Spacing.contentTightIntraVert,
        direction: HoundDropDownDirection = .down
    ) {
        self.identifier = identifier
        self.dropDownDataSource = dataSource
        self.viewPositionReference = viewPositionReference
        self.dropDownViewWidth = viewPositionReference.width
        self.dropDownViewOffset = offset
        self.direction = direction
        
        // The shadow on self so it can expand as much as it wants, border on dropDownTableView so it and the subviews can be masked / clipped.
        self.shadowColor = UIColor.label
        self.shadowOffset = CGSize(width: 0, height: 2.5)
        self.shadowRadius = 5.0
        self.shadowOpacity = 0.5
        
        let originY: CGFloat
        if direction == .down {
            originY = viewPositionReference.maxY + offset
        }
        else {
            originY = viewPositionReference.minY - offset
        }
        self.frame = CGRect(x: viewPositionReference.minX, y: originY, width: 0, height: 0)
        
        let dropDownTableView = HoundTableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.dropDownTableView = dropDownTableView
        
        dropDownTableView.rowHeight = HoundDropDownTVC.height
        dropDownTableView.estimatedRowHeight = HoundDropDownTVC.height
        dropDownTableView.register(HoundDropDownTVC.self, forCellReuseIdentifier: HoundDropDownTVC.reuseIdentifier)
        
        // The shadow on self so it can expand as much as it wants, border on dropDownTableView so it and the subviews can be masked / clipped.
        dropDownTableView.applyStyle(.thinGrayBorder)
        
        if direction == .up {
            dropDownTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
        
        dropDownTableView.delegate = self
        dropDownTableView.dataSource = self
        
        self.addSubview(dropDownTableView)
    }
    
    /// Shows Drop Down Menu, hides it if already present. The height of the dropdown shown will be equal to the rowHeight of the individual dropdown cells multiplied by the numberOfRowsToShow
    func showDropDown(numberOfRowsToShow numberOfRows: CGFloat, animated: Bool, direction: HoundDropDownDirection? = nil) {
        guard let identifier = identifier else {
            return
        }
        
        guard isDown == false else {
            self.hideDropDown(animated: animated)
            return
        }
        
        guard let dropDownTableView = dropDownTableView, let viewPositionReference = viewPositionReference else { return }
        
        self.direction = direction ?? self.direction
        
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
        let anchorY: CGFloat
        if direction == .down {
            anchorY = viewPositionReference.maxY + dropDownViewOffset
        }
        else {
            anchorY = viewPositionReference.minY - dropDownViewOffset
        }
        
        self.frame = CGRect(x: viewPositionReference.minX, y: anchorY, width: dropDownViewWidth, height: 0)
        dropDownTableView.frame = CGRect(x: 0, y: 0, width: dropDownViewWidth, height: 0)
        
        let shadowPad = max((self.shadowRadius ?? 0.0) + (self.shadowOffset?.height ?? 0.0), 0.0)
        
        let availableSpace: CGFloat
        if direction == .down {
            availableSpace = max((self.superview?.frame.height ?? 0.0) - anchorY - shadowPad, 0.0)
        }
        else {
            availableSpace = max(anchorY - shadowPad, 0.0)
        }
        
        // First, we don't want to make the drop down larger than the space needed to display all of its content. So we limit its size to the theoretical maximum space it would need to display all of its content
        // Second, we don't want the drop down larger than the available space in the superview. So we cap its size at the available vertical space.
        let height = min(min(heightSpecifiedForNumberOfRows, heightNeededToDisplayAllRows), availableSpace)
        
        UIView.animate(withDuration: animated ? 0.7 : 0.0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear, animations: {
            //            if self.direction == .up {
            //                self.frame.origin.y = anchorY - height
            //            }
            //            self.frame.size = CGSize(width: self.dropDownViewWidth, height: height)
            if self.direction == .down {
                self.frame.size = CGSize(width: self.dropDownViewWidth, height: height)
            }
            else {
                self.frame = CGRect(x: self.frame.minX, y: viewPositionReference.minY - self.dropDownViewOffset - height, width: self.dropDownViewWidth, height: height)
            }
            
            dropDownTableView.frame.size = CGSize(width: self.dropDownViewWidth, height: height)
        })
        
    }
    
    /// Hides DropDownMenu
    func hideDropDown(animated: Bool) {
        guard isDown else { return }
        
        isDown = false
        
        let originY: CGFloat
        if let viewPositionReference = viewPositionReference {
            if direction == .down {
                originY = viewPositionReference.maxY + dropDownViewOffset
            }
            else {
                originY = viewPositionReference.minY - dropDownViewOffset
            }
        }
        else {
            originY = frame.minY
        }
        
        UIView.animate(withDuration: animated ? 0.5 : 0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveLinear, animations: {
            if self.direction == .up {
                self.frame.origin.y = originY
            }
            self.frame.size = CGSize(width: self.dropDownViewWidth, height: 0)
            //            if self.direction == .up, let viewPositionReference = self.viewPositionReference {
            //                self.frame = CGRect(x: self.frame.minX, y: viewPositionReference.minY - self.dropDownViewOffset, width: self.dropDownViewWidth, height: 0)
            //            }
            //            else {
            //                self.frame.size = CGSize(width: self.dropDownViewWidth, height: 0)
            //            }
            self.dropDownTableView?.frame.size = CGSize(width: self.dropDownViewWidth, height: 0)
        })
    }
}
