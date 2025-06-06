//
//  GeneralUITableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralUITableViewCell: UITableViewCell, GeneralUIProtocol, GeneralUIKitProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]
    
    // MARK: - GeneralUIProtocol
    
    internal func setupGeneratedViews() {
        addSubViews()
        setupConstraints()
    }
    
    internal func addSubViews() {
        return
    }
    
    internal func setupConstraints() {
        return
    }
    
    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGeneratedViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGeneratedViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGeneratedViews()
    }

}
