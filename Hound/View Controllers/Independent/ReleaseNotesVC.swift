//
//  ReleaseNotesVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

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
        let titleAttr: [NSAttributedString.Key: Any] = [.font: Constant.VisualFont.emphasizedPrimaryRegularLabel]
        let descAttr: [NSAttributedString.Key: Any] = [.font: Constant.VisualFont.primaryRegularLabel]
        
        let message = NSMutableAttributedString()
        
        for item in items {
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
        
        // TODO RELEASE NOTES make this page snazzier. see reference image from other app
        
        // TODO RELEASE NOTES 3.5.0 UPDATE W/ NEW FEATURES
        // 1. triggers
        // 2. redone ui for scalability / iPad
        // 3. skippable reminders
        // 4. ability to duplicate reminders
        // 5. ability to search by filter text and filter by time range
        // 6. log end time is now "in x time" rather than "ago x time"
        // 7. this custom page itself
        // 8. new app icon
        var builder = ReleaseNotesBuilder()
        builder.addFeature(
            title: "Automations",
            description: "Automate your dog's logs with customizable automations."
        )
        builder.addFeature(
            title: "Redesigned UI",
            description: "Interface rebuilt for scalability and iPad support."
        )
        builder.addFeature(
            title: "Skippable Reminders",
            description: "Want to forgo your reminder's next alarm? Now you can!"
        )
        builder.addFeature(
            title: "Duplicate Reminders",
            description: "Quickly create a copy of any reminder."
        )
        builder.addFeature(
            title: "Enhanced Search",
            description: "Filter reminders by text or by time range."
        )
        builder.addFeature(
            title: "Smarter Log Time",
            description: "Log end time now shows 'in x time' rather than 'ago x time'."
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
