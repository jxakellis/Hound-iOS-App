//
//  LogTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

protocol LogTVCDelegate: AnyObject {
    func didUpdateLogLikes(sender: Sender, dogUUID: UUID, log: Log)
    func shouldShowLogLikes(log: Log)
}

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
    
    private lazy var likeButton: HoundButton = {
        let button = HoundButton(type: .system)
//        button.setImage(UIImage(systemName: "heart"), for: .normal)
//        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        
        let likeAction = UIAction { [weak self] _  in
            guard let self = self else { return }
            guard let dogUUID = self.dogUUID, let log = self.log else { return }
            guard let userId = UserInformation.userId else { return }
            
            HapticsManager.selectionChanged()
            
            let currentlyLiked = log.likedByUserIds.contains(userId)
            log.setLogLike(!currentlyLiked)
            delegate?.didUpdateLogLikes(sender: Sender(source: self, lastLocation: self), dogUUID: dogUUID, log: log)
            updateLikeButtonBadge(animated: true)
            
            button.isEnabled = false
            LogsRequest.update(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, log: log) { responseStatus, _ in
                button.isEnabled = true
                // if success response or no response, then its fine and acceptable (offline mode can handle it)
                guard responseStatus == .failureResponse else {
                    return
                }
                
                // undo the like b/c it failed
                log.setLogLike(currentlyLiked)
                self.delegate?.didUpdateLogLikes(sender: Sender(source: self, lastLocation: self), dogUUID: dogUUID, log: log)
                self.updateLikeButtonBadge(animated: true)
            }
        }
        
        let showLikesAction = UIAction { [weak self] _  in
            guard let self = self else { return }
            guard let log = log else { return }
            
            HapticsManager.selectionChanged()
            
            delegate?.shouldShowLogLikes(log: log)
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLikeButtonLongPress(_:)))
        
        button.addAction(likeAction, for: .touchUpInside)
        button.addGestureRecognizer(longPressGesture)
        return button
    }()
    
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
    
    @objc private func handleLikeButtonLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return } // Only trigger once per long-press
        guard let log = log else { return }
        HapticsManager.selectionChanged()
        delegate?.shouldShowLogLikes(log: log)
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "LogTVC"
    
    private var infoItems: [String] = []
    
    private weak var delegate: LogTVCDelegate?
    private var dogUUID: UUID?
    private var log: Log?
    
    // MARK: - Setup
    
    /// Configure the cell’s labels and adjust dynamic constraints based on the provided Log
    func setup(delegate: LogTVCDelegate, dogName: String, dogUUID: UUID, log: Log, sort: LogsSort, filter: LogsFilter) {
        self.delegate = delegate
        self.dogUUID = dogUUID
        self.log = log
        
        // depending on the different sort methods, the logs displayed will be grouped and displayed by different dates, thus affecting the headers (e.g. you have a group "Today" of logs but that could be Today for start date, or created date, etc...
        // thus if times are relative, e.g. 8:50AM, they need to be relative to this header
        let cellGroupedByDate = sort.dateType.dateForDateType(log)
        
        func convertDateToRelative(_ convert: Date) -> String {
            if Calendar.user.isDate(convert, inSameDayAs: cellGroupedByDate) {
                // date is same day as the header for this grouping of logs in the table
                // e.g. both may 15th, so we can simply display 8:50AM
                return convert.houndFormatted(.formatStyle(date: .omitted, time: .shortened), displayTimeZone: UserConfiguration.timeZone)
            }
            else {
                // date is a different day/month and potentially year from the header
                // e.g. this grouping is for may 15th but this date is from may 25th
                let cellGroupedByDateYear = Calendar.user.component(.year, from: cellGroupedByDate)
                let currentYear = Calendar.user.component(.year, from: Date())
                return convert.houndFormatted(.template(cellGroupedByDateYear == currentYear ? "MMMd" : "MMMdyy"), displayTimeZone: UserConfiguration.timeZone)
            }
        }
        
        logActionIconLabel.text = log.logActionType.emoji
        
        dogNameLabel.text = dogName
        
        logActionTextLabel.text = log.logActionType.convertToReadableName(customActionName: log.logCustomActionName, includeMatchingEmoji: false)
        
        // e.g., “7:53 AM”
        logStartToEndDateLabel.text = convertDateToRelative(log.logStartDate)
        
        if let logEndDate = log.logEndDate {
            logStartToEndDateLabel.text = logStartToEndDateLabel.text?.appending(" - \(convertDateToRelative(logEndDate))")
        }
        
        let previousLogDurationText = logDurationLabel.text
        logDurationLabel.text = {
            guard let logEndDate = log.logEndDate else {
                return nil
            }
            return log.logStartDate.distance(to: logEndDate).readable(capitalizeWords: false, abbreviationLevel: .short, maxComponents: 2, enforceSequentialComponents: true)
        }()
        
        updateLikeButtonBadge(animated: false)
        
        let previousInfoItems = infoItems
        infoItems = []
        if sort.dateType == .createdDate || filter.timeRangeField == .createdDate {
            let dateString = convertDateToRelative(log.logCreated)
            infoItems.append("Created: \(dateString)")
        }
        if sort.dateType == .modifiedDate || filter.timeRangeField == .modifiedDate {
            let dateString = convertDateToRelative(log.logLastModified ?? log.logCreated)
            infoItems.append("Modified: \(dateString)")
        }
        if let unitType = log.logUnitType, let numUnits = log.logNumberOfLogUnits, let unit = unitType.pluralReadableValueWithNumUnits(logNumberOfLogUnits: numUnits) {
            infoItems.append(unit)
        }
        let trimmedNote = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedNote.isEmpty == false {
            infoItems.append(trimmedNote)
        }
        
        let infoItemsChanged = previousInfoItems != infoItems
        if infoItemsChanged {
            infoBubbleCollectionView.reloadData()
            remakeInfoBubbleConstraints()
        }
        
        let logDurationChange = previousLogDurationText != logDurationLabel.text
        if logDurationChange || infoItemsChanged {
            remakeLikeButtonConstraints()
        }
        
        if logDurationChange || infoItemsChanged {
            // cell's height changed so table view needs to relay it out to give it the proper vertical space it needs
            findParentTableViewAndRelayoutCells()
        }
    }
    
    // MARK: - Functions
    
    private func updateLikeButtonBadge(animated: Bool) {
        let duration = animated ? Constant.Visual.Animation.selectSingleElement : 0.0
        
        let isLiked: Bool
        if let userId = UserInformation.userId {
            isLiked = self.log?.likedByUserIds.contains(userId) == true
        }
        else {
            isLiked = false
        }
        
        UIView.transition(with: likeButton, duration: duration, options: .transitionCrossDissolve) {
            self.likeButton.setImage(isLiked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"), for: .normal)
            self.likeButton.setImage(isLiked ? UIImage(systemName: "heart") : UIImage(systemName: "heart.fill"), for: .selected)
            self.likeButton.tintColor = isLiked ? .systemRed : .systemGray2
            self.likeButton.badgeValue = self.log?.likedByUserIds.count
            self.likeButton.badgeVisible = self.log?.likedByUserIds.isEmpty == false
        }
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(topStack)
        containerView.addSubview(infoBubbleCollectionView)
        containerView.addSubview(likeButton)
    }
    
    private func remakeLikeButtonConstraints() {
        let shouldBeInStack = infoItems.isEmpty && logDurationLabel.text == nil
        
        likeButton.snp.remakeConstraints { make in
            if shouldBeInStack {
                // TODO TEST this might become funky for big screen sizes and overlap with stuff
                make.centerY.equalTo(logActionLogDurationStack.snp.centerY)
            }
            else {
                make.top.greaterThanOrEqualTo(topStack.snp.bottom).offset(Constant.Constraint.Spacing.contentTightIntraVert)
                make.leading.equalTo(infoBubbleCollectionView.snp.trailing).offset(Constant.Constraint.Spacing.contentIntraHori)
            }
            make.bottom.equalTo(containerView.snp.bottom).inset(Constant.Constraint.Spacing.contentIntraVert)
            make.trailing.equalTo(containerView.snp.trailing).inset(Constant.Constraint.Spacing.absoluteHoriInset)
            
            make.height.equalTo(contentView.snp.width).multipliedBy(Constant.Constraint.Button.tinyHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Button.tinyMaxHeight)
            make.width.equalTo(likeButton.snp.height)
        }
    }
    
    private func remakeInfoBubbleConstraints() {
        // topStack can conflict with infoBubbleCollectionView before its remade
        infoBubbleCollectionView.snp.removeConstraints()
        
        infoBubbleCollectionView.isHidden = infoItems.isEmpty
        
        infoBubbleCollectionView.snp.makeConstraints { make in
            make.leading.equalTo(containerView).inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        
        guard !infoItems.isEmpty else {
            return
        }
        
        infoBubbleCollectionView.snp.makeConstraints { make in
            make.top.equalTo(topStack.snp.bottom).offset(Constant.Constraint.Spacing.contentIntraVert)
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
        
        topStack.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(Constant.Constraint.Spacing.contentIntraVert)
            make.leading.trailing.equalTo(containerView).inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        
        remakeInfoBubbleConstraints()
        
        remakeLikeButtonConstraints()
    }
    
}
