//
//  HoundPageSheetHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/25/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

final class HoundPageSheetHeaderView: HoundView {
    
    // MARK: - Elements
    
    lazy var pageHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 500, compressionResistancePriority: 500)
        label.text = "Default Page Header"
        label.font = Constant.Visual.Font.primaryHeaderLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = useLeftTextAlignment ? .left : .center
        return label
    }()
    
    let backButton: HoundButton = {
        let button = HoundButton(huggingPriority: 490, compressionResistancePriority: 490)
        
        button.tintColor = UIColor.label
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.backgroundCircleTintColor = UIColor.systemBackground
        
        button.shouldRoundCorners = true
        button.shouldDismissParentViewController = true
        return button
    }()
    
    lazy var pageDescriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 480, compressionResistancePriority: 480)
        label.text = "Default Page Description"
        label.font = Constant.Visual.Font.tertiaryHeaderLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = useLeftTextAlignment ? .left : .center
        label.isHidden = !isDescriptionEnabled
        return label
    }()
    
    // MARK: - Properties
    
    var useLeftTextAlignment: Bool = true {
        didSet {
            pageHeaderLabel.textAlignment = useLeftTextAlignment ? .left : .center
            pageDescriptionLabel.textAlignment = useLeftTextAlignment ? .left : .center
            remakeHeaderAndDescriptionConstraints()
        }
    }
    
    var isDescriptionEnabled: Bool = false {
        didSet {
            pageDescriptionLabel.isHidden = !isDescriptionEnabled
            remakeHeaderAndDescriptionConstraints()
        }
    }
    
    // MARK: - Functions
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        self.addSubview(backButton)
        self.addSubview(pageHeaderLabel)
        self.addSubview(pageDescriptionLabel)
    }
    
    private func remakeHeaderAndDescriptionConstraints() {
        // in the process of remaking header constraints when description is still active (not remade yet), may run into issues, so remove description first
        pageDescriptionLabel.snp.removeConstraints()
        
        pageHeaderLabel.snp.remakeConstraints { make in
            make.top.equalTo(self.snp.top).offset(Constant.Constraint.Spacing.absoluteVertInset)
            if useLeftTextAlignment {
                make.leading.equalTo(self.snp.leading).offset(Constant.Constraint.Spacing.absoluteHoriInset)
            }
            else {
                make.centerX.equalTo(self.snp.centerX)
            }
            
            if pageDescriptionLabel.isHidden {
                make.bottom.equalTo(self.snp.bottom)
            }
        }
        
        pageDescriptionLabel.snp.remakeConstraints { make in
            if !pageDescriptionLabel.isHidden {
                make.top.equalTo(pageHeaderLabel.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
                make.bottom.equalTo(self.snp.bottom)
                make.horizontalEdges.equalTo(self.snp.horizontalEdges).inset(Constant.Constraint.Spacing.absoluteHoriInset)
            }
        }
    }
    override func setupConstraints() {
        super.setupConstraints()
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(Constant.Constraint.Spacing.absoluteVertInset)
            // the header should be at least as tall as the back btn
            make.bottom.lessThanOrEqualTo(self.snp.bottom)
            make.leading.equalTo(pageHeaderLabel.snp.trailing).offset(Constant.Constraint.Spacing.contentTightIntraHori)
            make.trailing.equalTo(self.snp.trailing).inset(Constant.Constraint.Spacing.absoluteCircleHoriInset)
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Button.circleHeightMultiplier)
            make.height.lessThanOrEqualTo(Constant.Constraint.Button.circleMaxHeight)
            make.width.equalTo(backButton.snp.height)
        }
        
        remakeHeaderAndDescriptionConstraints()
        
    }

}
