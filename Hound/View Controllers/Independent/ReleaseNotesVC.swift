//
//  ReleaseNotesVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class ReleaseNotesVC: HoundScrollViewController {
    
    // MARK: - Elements
    private let pageHeaderView: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView(huggingPriority: 350, compressionResistancePriority: 350)
        view.useLeftTextAlignment = false
        
        view.isDescriptionEnabled = true
        view.pageDescriptionLabel.text = "🎉  🦮  🎉  🦮  🎉  🦮  🎉"
        return view
    }()
    
    private let notesLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.numberOfLines = 0
        label.textColor = UIColor.label
        return label
    }()
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
    }
    
    func setup(version: AppVersion) {
        pageHeaderView.pageHeaderLabel.text = "What's New in v\(version.rawValue)"
        notesLabel.attributedText = version.releaseNotes
    }
    
    // MARK: - Setup Elements
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBackground
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        containerView.addSubview(pageHeaderView)
        containerView.addSubview(notesLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        NSLayoutConstraint.activate([
            pageHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            notesLabel.topAnchor.constraint(equalTo: pageHeaderView.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert),
            notesLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            notesLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            notesLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset)
        ])
    }
}
