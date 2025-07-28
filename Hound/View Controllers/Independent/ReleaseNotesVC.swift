//
//  ReleaseNotesVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ReleaseNoteImportance {
    case minor
    case normal
}

struct ReleaseNoteItem {
    let title: String
    let description: String
}

struct ReleaseNotesBuilder {
    private var items: [ReleaseNoteItem] = []
    
    mutating func addFeature(title: String, description: String) {
        items.append(ReleaseNoteItem(title: title, description: description))
    }
    
    func buildAttributedString() -> NSAttributedString {
        let message = NSMutableAttributedString()
        
        for item in items {
            let titleAttr: [NSAttributedString.Key: Any] = [.font: Constant.Visual.Font.emphasizedPrimaryRegularLabel]
            let descAttr: [NSAttributedString.Key: Any] = [.font: Constant.Visual.Font.primaryRegularLabel]
            
            message.append(NSAttributedString(string: "\u{2022} \(item.title)\n", attributes: titleAttr))
            message.append(NSAttributedString(string: item.description, attributes: descAttr))
            message.append(NSAttributedString(string: "\n\n"))
        }
        return message
    }
}

final class ReleaseNotesVC: HoundScrollViewController {
    
    // MARK: - Elements
    private let pageHeaderView: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView(huggingPriority: 350, compressionResistancePriority: 350)
        view.useLeftTextAlignment = false
        view.pageHeaderLabel.text = "What's New in v\(UIApplication.appVersion)"
        
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
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        // TODO RELEASE NOTES
        // ability to enable / disable haptics
        // reminder timing calculation changes
        // per reminder notification settings

        var builder = ReleaseNotesBuilder()
        builder.addFeature(
            title: "Automations",
            description: "Hound can now create reminders for you when you add certain logs.\n\nFor example, setup an automation to get reminded to take Bella out 30 mins after you feed her!"
        )
        
        builder.addFeature(
            title: "Fresh Interface",
            description: "A snazzy look built to shine on iPad, plus a slew of visual enhancements"
        )
        
        builder.addFeature(
            title: "More Filter Options",
            description: "Filter your logs by text or time range to fetch just what you need"
        )
        
        builder.addFeature(
            title: "New Log Type",
            description: "When your dog doesn't eat, now you can add a \"Did't Eat 🍽️\" log to track it!"
        )
        
        builder.addFeature(
            title: "Skippable Reminders",
            description: "Easily skip a reminder when playtime runs long."
        )
        
        builder.addFeature(
            title: "Duplicate Reminders",
            description: "Copy a reminder and tweak the details in seconds."
        )
        
        builder.addFeature(
            title: "Release Notes",
            description: "This page keeps you up to date on every new trick."
        )
        
        builder.addFeature(
            title: "New App Icon",
            description: "Spot Hound faster with our crisp new look."
        )
        
        notesLabel.attributedText = builder.buildAttributedString()
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
