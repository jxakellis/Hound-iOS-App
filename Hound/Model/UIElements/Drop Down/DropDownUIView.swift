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

final class DropDownUIView: UIView {
    
    // MARK: - Static
    
    /// Leading and trailing inset for labels inside drop down. 8.0 aligns properly with the inset from a  GeneralUILabel
    static let insetForGeneralUILabel: CGFloat = 8.0
    /// Leading and trailing inset for labels inside drop down.
    static let insetForLogFilter: CGFloat = 12.0
    
    /// Height of each row in the dropdownuiview, should be same height as the GeneralUIlabel that it presents on
    static let rowHeightForGeneralUILabel: CGFloat = 40.0
    /// Height of each row in the dropdownuiview
    static let rowHeightForLogFilter: CGFloat = 30.0
    
    // MARK: - Variables
    
    /// The DropDownIdentifier is to differentiate if you are using multiple Xibs
    var dropDownUIViewIdentifier: String = "DROP_DOWN"
    /// Reuse Identifier of your custom cell
    var cellReusableIdentifier: String = "DROP_DOWN_CELL"
    // Table View
    var dropDownTableView: UITableView?
    private var width: CGFloat = 0
    private var offset: CGFloat = 0
    var dataSource: DropDownUIViewDataSource?
    var nib: UINib? {
        didSet {
            dropDownTableView?.register(nib, forCellReuseIdentifier: self.cellReusableIdentifier)
        }
    }
    // Other Variables
    private var viewPositionRef: CGRect?
    private(set) var isDown: Bool = false
    
    // MARK: - DropDown Methods
    
    /// Make Table View Programatically
    func setupDropDown(viewPositionReference: CGRect, offset: CGFloat) {
        self.addBorders()
        self.addShadowToView()
        // dropDownStyle = UserConfiguration.interfaceStyle
        self.frame = CGRect(x: viewPositionReference.minX, y: viewPositionReference.maxY + offset, width: 0, height: 0)
        dropDownTableView = UITableView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: 0, height: 0))
        self.width = viewPositionReference.width
        self.offset = offset
        self.viewPositionRef = viewPositionReference
        dropDownTableView?.showsVerticalScrollIndicator = false
        dropDownTableView?.showsHorizontalScrollIndicator = false
        dropDownTableView?.backgroundColor = .systemBackground
        dropDownTableView?.separatorStyle = .none
        dropDownTableView?.delegate = self
        dropDownTableView?.dataSource = self
        dropDownTableView?.allowsSelection = true
        dropDownTableView?.isUserInteractionEnabled = true
        dropDownTableView?.tableFooterView = UIView()
        if let dropDownTableView = dropDownTableView {
            self.addSubview(dropDownTableView)
        }
    }
    
    /// Shows Drop Down Menu, hides it if already present. The height of the dropdown shown will be equal to the rowHeight of the individual dropdown cells multiplied by the numberOfRowsToShow
    func showDropDown(numberOfRowsToShow numRows: CGFloat, animated: Bool) {
        guard isDown == false else {
            self.hideDropDown()
            return
        }
        
        guard let dropDownTableView = dropDownTableView, let viewPositionRef = viewPositionRef else {
            return
        }
        
        let height = numRows * dropDownTableView.rowHeight
        reloadDropDownData()
        reloadBorderShadowColor()
        isDown = true
        self.frame = CGRect(x: viewPositionRef.minX, y: viewPositionRef.maxY + self.offset, width: width, height: 0)
        dropDownTableView.frame = CGRect(x: 0, y: 0, width: width, height: 0)
        
        UIView.animate(withDuration: animated ? 0.7 : 0.0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear, animations: {
            self.frame.size = CGSize(width: self.width, height: height)
            dropDownTableView.frame.size = CGSize(width: self.width, height: height)
        })
        
    }
    
    /// Reloads table view data
    private func reloadDropDownData() {
        self.dropDownTableView?.reloadData()
    }
    
    /// If switched from light to dark mode or vise versa, cgColor based border and shadow do not update on their own, must do manually. Must be called whenever dropdown is shown
    private func reloadBorderShadowColor() {
        // We have to update the borderShadowColor every time we show due to .unspecified for dark mode style. In this mode, if the user uses the control center to switch from dark to light (or vise versa), we have no way of knowing that our app switched colors. There fore must reload always
        self.addBorders()
        self.addShadowToView()
    }
    
    /// Sets Row Height of your Custom XIB
    func setRowHeight(height: CGFloat) {
        self.dropDownTableView?.rowHeight = height
        self.dropDownTableView?.estimatedRowHeight = height
    }
    
    /// Hides DropDownMenu
    func hideDropDown(removeFromSuperview shouldRemoveFromSuperview: Bool = false) {
        guard isDown else {
            return
        }
        
        isDown = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveLinear, animations: {
            self.frame.size = CGSize(width: self.width, height: 0)
            self.dropDownTableView?.frame.size = CGSize(width: self.width, height: 0)
        }) { (_) in
            if shouldRemoveFromSuperview == true {
                self.removeFromSuperview()
                self.dropDownTableView?.removeFromSuperview()
            }
            
        }
    }
}

// MARK: - Table View Methods

extension DropDownUIView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (dataSource?.numberOfSections(dropDownUIViewIdentifier: self.dropDownUIViewIdentifier) ?? 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataSource?.numberOfRows(forSection: section, dropDownUIViewIdentifier: self.dropDownUIViewIdentifier) ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = (dropDownTableView?.dequeueReusableCell(withIdentifier: self.cellReusableIdentifier) ?? UITableViewCell())
        
        dataSource?.setupCellForDropDown(cell: cell, indexPath: indexPath, dropDownUIViewIdentifier: self.dropDownUIViewIdentifier)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSource?.selectItemInDropDown(indexPath: indexPath, dropDownUIViewIdentifier: self.dropDownUIViewIdentifier)
    }
    
}
// MARK: - UIView Extension
extension UIView {
    
    func addBorders(borderWidth: CGFloat = 0.25, borderColor: CGColor = UIColor.systemGray2.cgColor) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor
    }
    
    func addShadowToView(shadowRadius: CGFloat = 2, alphaComponent: CGFloat = 0.4) {
        self.layer.shadowColor = UIColor.label.withAlphaComponent(alphaComponent).cgColor
        self.layer.shadowOffset = CGSize(width: -1, height: 2)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 1
    }
}
