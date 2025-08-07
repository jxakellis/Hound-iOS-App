//
//  LogTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

final class LogTVC: HoundTableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LogInfoBubbleCVC.reuseIdentifier, for: indexPath) as? LogInfoBubbleCVC else {
            return UICollectionViewCell()
        }
        cell.setup(text: infoItems[indexPath.item])
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let sectionInset = layout?.sectionInset ?? .zero
        let maxWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        cell.setMaxWidth(maxWidth)
        
        return cell
    }
    
    // MARK: - Elements
    
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.systemBackground
        return view
    }()
    
    private let logActionIconLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.textAlignment = .center
        // same as ReminderTVC
        label.font = UIFont.systemFont(ofSize: 42.5, weight: .medium)
        return label
    }()
    
    private let dogNameLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = Constant.Visual.Font.emphasizedPrimaryRegularLabel
        return label
    }()
    private let logStartToEndDateLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.textAlignment = .right
        label.font = Constant.Visual.Font.secondaryRegularLabel
        return label
    }()
    private lazy var dogNameLogDateStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(dogNameLabel)
        stack.addArrangedSubview(logStartToEndDateLabel)
        stack.axis = .horizontal
        stack.spacing = Constant.Constraint.Spacing.contentIntraHori
        stack.alignment = .center
        return stack
    }()
    
    private lazy var logActionTextLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = Constant.Visual.Font.primaryRegularLabel
        return label
    }()
    private let logDurationLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.textAlignment = .right
        label.font = Constant.Visual.Font.secondaryRegularLabel
        return label
    }()
    private lazy var logActionLogDurationStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(logActionTextLabel)
        stack.addArrangedSubview(logDurationLabel)
        stack.axis = .horizontal
        stack.spacing = Constant.Constraint.Spacing.contentIntraHori
        stack.alignment = .center
        return stack
    }()
    
    private lazy var dogNameLogDateLogActionLogDurationStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(dogNameLogDateStack)
        stack.addArrangedSubview(logActionLogDurationStack)
        stack.axis = .vertical
        stack.spacing = Constant.Constraint.Spacing.contentTightIntraVert
        return stack
    }()
    
    private lazy var topStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(logActionIconLabel)
        stack.addArrangedSubview(dogNameLogDateLogActionLogDurationStack)
        stack.axis = .horizontal
        stack.spacing = Constant.Constraint.Spacing.contentIntraHori
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    private var lastKnownCollectionViewHeight: CGFloat = 0
    private var infoBubbleCollectionViewHeight: Constraint?
    
    private lazy var infoBubbleCollectionView: UICollectionView = {
        let layout = HoundLeftAlignedCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constant.Constraint.Spacing.contentIntraHori
        layout.minimumLineSpacing = Constant.Constraint.Spacing.contentIntraVert
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .vertical

        let collectionView = HoundIntrinsicCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(LogInfoBubbleCVC.self, forCellWithReuseIdentifier: LogInfoBubbleCVC.reuseIdentifier)
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "LogTVC"
    
    private var infoItems: [String] = []
    
    private weak var delegate: LogTVCDelegate?
    
    // MARK: - Setup
    
    /// Configure the cell’s labels and adjust dynamic constraints based on the provided Log
    func setup(delegate: LogTVCDelegate, dogName: String, log: Log, sort: LogsSort, filter: LogsFilter) {
        // TODO the relativity of all of these log displays need to be diff, b/c depending upon sort mode, the today/yesterday for each header for the logs grouped that are on the same day change
        self.delegate = delegate
        logActionIconLabel.text = log.logActionType.emoji
        
        // Pad label so it lines up with other labels
        dogNameLabel.text = dogName
        
        logActionTextLabel.text = log.logActionType.convertToReadableName(customActionName: log.logCustomActionName, includeMatchingEmoji: false)
        
        // e.g., “7:53 AM”
        logStartToEndDateLabel.text = log.logStartDate.houndFormatted(.formatStyle(date: .omitted, time: .shortened), displayTimeZone: UserConfiguration.timeZone)
        
        if let logEndDate = log.logEndDate {
            let endString: String
            // dont use inSameDayAs, b/c take alarm at 11:59PM to 12:01AM, then we would show 11:59PM - Aug 5 (assuming 11:59PM on Aug 4)
            if log.logStartDate.distance(to: logEndDate) < 60 * 60 * 24 {
                // Same day: no need for date information
                endString = logEndDate.houndFormatted(.formatStyle(date: .omitted, time: .shortened), displayTimeZone: UserConfiguration.timeZone)
            }
            else {
                // Different day: show month + day (and year if not current)
                let logEndYear = Calendar.user.component(.year, from: logEndDate)
                let currentYear = Calendar.user.component(.year, from: Date())
                endString = logEndDate.houndFormatted(.template(logEndYear == currentYear ? "MMMd" : "MMMdyy"), displayTimeZone: UserConfiguration.timeZone)
            }
            logStartToEndDateLabel.text = logStartToEndDateLabel.text?.appending(" - \(endString)")
        }
        
        logDurationLabel.text = {
            guard let logEndDate = log.logEndDate else {
                return nil
            }
            return log.logStartDate.distance(to: logEndDate).readable(capitalizeWords: false, abbreviationLevel: .short, maxComponents: 2, enforceSequentialComponents: true)
        }()
        
        infoItems = []
        if sort.sortField == .createdDate || filter.timeRangeField == .createdDate {
            let dateString = log.logCreated .houndFormatted(.formatStyle(date: .omitted, time: .shortened), displayTimeZone: UserConfiguration.timeZone)
            infoItems.append("Created: \(dateString)")
        }
        if sort.sortField == .modifiedDate || filter.timeRangeField == .modifiedDate {
            let dateString = LogsSortField.modifiedDate.date(log).houndFormatted(.formatStyle(date: .omitted, time: .shortened), displayTimeZone: UserConfiguration.timeZone)
            infoItems.append("Modified: \(dateString)")
        }
        if let unitType = log.logUnitType, let numUnits = log.logNumberOfLogUnits, let unit = unitType.pluralReadableValueWithNumUnits(logNumberOfLogUnits: numUnits) {
            infoItems.append(unit)
        }
        let trimmedNote = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedNote.isEmpty == false {
            infoItems.append(trimmedNote)
        }
        
        remakeInfoBubbleConstraints()
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(topStack)
        containerView.addSubview(infoBubbleCollectionView)
    }
    
    private func remakeInfoBubbleConstraints() {
        // topStack can conflict with infoBubbleCollectionView before its remade
        infoBubbleCollectionView.snp.removeConstraints()
        
        topStack.snp.remakeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(Constant.Constraint.Spacing.absoluteVertInset)
            make.leading.trailing.equalTo(containerView).inset(Constant.Constraint.Spacing.absoluteHoriInset)

            if infoItems.isEmpty {
                make.bottom.equalTo(containerView.snp.bottom).inset(Constant.Constraint.Spacing.contentIntraVert)
            }
        }

        infoBubbleCollectionView.isHidden = infoItems.isEmpty

        guard !infoItems.isEmpty else {
            return
        }

        infoBubbleCollectionView.snp.remakeConstraints { make in
            make.top.equalTo(topStack.snp.bottom).offset(Constant.Constraint.Spacing.contentIntraVert)
            make.leading.trailing.equalTo(containerView).inset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.bottom.equalTo(containerView.snp.bottom).inset(Constant.Constraint.Spacing.contentIntraVert)
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            // Use .high priority to avoid breaking during table view height estimation
            make.bottom.equalTo(contentView.snp.bottom).priority(.high)
            make.horizontalEdges.equalTo(contentView.snp.horizontalEdges).inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        
        remakeInfoBubbleConstraints()
    }
    
}
