//
//  LogLikesTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/7/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

final class LogLikesTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    let containerView: HoundView = {
        let view = HoundView()
        return view
    }()
    
    private let heartImageView: HoundImageView = {
        let imageView = HoundImageView()
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = UIColor.systemPink
        return imageView
    }()
    
    private let displayFullNameLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.primaryRegularLabel
        return label
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "LogLikesTVC"
    
    // MARK: - Setup
    
    func setup(displayFullName: String) {
        displayFullNameLabel.text = displayFullName
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(heartImageView)
        containerView.addSubview(displayFullNameLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            // Use .high priority to avoid breaking during table view height estimation
            make.bottom.equalTo(contentView.snp.bottom).priority(.high)
            make.horizontalEdges.equalTo(contentView.snp.horizontalEdges).inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        
        heartImageView.snp.makeConstraints { make in
            make.leading.equalTo(containerView.snp.leading)
            make.centerY.equalTo(displayFullNameLabel.snp.centerY)
            
            make.height.equalTo(contentView.snp.width).multipliedBy(Constant.Constraint.Button.miniHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Button.miniMaxHeight)
            make.width.equalTo(heartImageView.snp.height)
        }
        
        displayFullNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(heartImageView.snp.trailing).offset(Constant.Constraint.Spacing.contentIntraHori)
            make.trailing.equalTo(containerView.snp.trailing)
            make.verticalEdges.equalTo(containerView).inset(Constant.Constraint.Spacing.contentIntraVert)
        }
    }
}
