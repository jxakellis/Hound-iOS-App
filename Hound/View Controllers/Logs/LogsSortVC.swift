//
//  LogsSortVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/4/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

// TODO QOL add a leave without save warning

protocol LogsSortDelegate: AnyObject {
    func didUpdateLogsSort(logsSort: LogsSort)
}

enum LogsSortDropDownTypes: String, HoundDropDownType {
    case sortField = "SortField"
    case sortDirection = "SortDirection"
}

class LogsSortVC: HoundScrollViewController,
                  HoundDropDownDataSource,
                  HoundDropDownManagerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Elements
    
    private let pageHeaderView: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView(huggingPriority: 350, compressionResistancePriority: 350)
        view.pageHeaderLabel.text = "Sort"
        return view
    }()
    
    // TODO UI think of better names that "Field" and "Order" for this
    private let sortFieldHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Field"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    private lazy var sortFieldLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.shouldInsetText = true
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: LogsSortDropDownTypes.sortField,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .sortField, label: label, autoscroll: .firstOpen)
        
        return label
    }()
    private lazy var sortFieldStack: HoundStackView = {
        let stack = HoundStackView.inputFieldStack(sortFieldHeaderLabel)
        stack.addArrangedSubview(sortFieldLabel)
        return stack
    }()
    
    private let sortDirectionHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Order"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    private lazy var sortDirectionLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.applyStyle(.thinGrayBorder)
        label.shouldInsetText = true
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            dropDownManager.showHideDropDownGesture(
                identifier: LogsSortDropDownTypes.sortDirection,
                delegate: self
            )
        )
        dropDownManager.register(identifier: .sortDirection, label: label, autoscroll: .firstOpen)
        
        return label
    }()
    private lazy var sortDirectionStack: HoundStackView = {
        let stack = HoundStackView.inputFieldStack(sortDirectionHeaderLabel)
        stack.addArrangedSubview(sortDirectionLabel)
        return stack
    }()
    
    private lazy var applyButton: HoundButton = {
        let button = HoundButton(huggingPriority: 230, compressionResistancePriority: 230)
        
        button.setTitle("Apply", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = Constant.Visual.Font.wideButton
        
        button.backgroundColor = UIColor.systemBlue
        
        button.shouldRoundCorners = true
        
        button.shouldDismissParentViewController = true
        
        button.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var resetButton: HoundButton = {
        let button = HoundButton(huggingPriority: 220, compressionResistancePriority: 220)
        
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = Constant.Visual.Font.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
        button.applyStyle(.labelBorder)
        
        button.shouldDismissParentViewController = true
        
        button.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var dropDownManager = HoundDropDownManager<LogsSortDropDownTypes>(
        rootView: containerView,
        dataSource: self,
        delegate: self
    )
    
    @objc private func didTapApply(_ sender: Any) {
        guard let sort = sort else { return }
        delegate?.didUpdateLogsSort(logsSort: sort)
    }
    
    @objc private func didTapReset(_ sender: Any) {
        sort?.reset()
        if let sort = sort {
            delegate?.didUpdateLogsSort(logsSort: sort)
        }
    }
    
    // MARK: - Properties
    
    private weak var delegate: LogsSortDelegate?
    
    private var sort: LogsSort?
    
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
        self.enableSwipeBackToDismiss = true
        
        updateDynamicUIElements()
    }
    
    private var didSetupCustomSubviews: Bool = false
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        guard didSetupCustomSubviews == false else { return }
        
        didSetupCustomSubviews = true
        
        updateDynamicUIElements()
    }
    
    // MARK: - Setup
    
    func setup(delegate: LogsSortDelegate, sort: LogsSort) {
        self.delegate = delegate
        self.sort = (sort.copy() as? LogsSort) ?? self.sort
    }
    
    // MARK: - Functions
    
    private func updateDynamicUIElements() {
        if let sort = sort {
            sortFieldLabel.text = sort.sortField.readableValue
            sortDirectionLabel.text = sort.sortDirection.readableValue
        }
    }
    
    // MARK: - Drop Down
    
    @objc private func didTapScreen(sender: UITapGestureRecognizer) {
        dropDownManager.hideDropDownIfNotTapped(sender: sender)
    }
    
    func willShowDropDown(_ identifier: any HoundDropDownType, animated: Bool) {
        guard let sort = sort else { return }
        guard let type = identifier as? LogsSortDropDownTypes else { return }
        
        let rows: CGFloat = {
            switch type {
            case .sortField: return CGFloat(sort.availableFields.count)
            case .sortDirection: return CGFloat(sort.availableDirections.count)
            }
        }()
        
        dropDownManager.show(
            identifier: type,
            numberOfRowsToShow: min(6.5, rows),
            animated: animated
        )
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: HoundDropDownTVC, indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let sort = sort else { return }
        guard let type = identifier as? LogsSortDropDownTypes else { return }
        switch type {
        case .sortField:
            let field = sort.availableFields[indexPath.row]
            cell.setCustomSelected(sort.sortField == field, animated: false)
            cell.label.text = field.readableValue
        case .sortDirection:
            let direction = sort.availableDirections[indexPath.row]
            cell.setCustomSelected(sort.sortDirection == direction, animated: false)
            cell.label.text = direction.readableValue
        }
    }
    
    func numberOfRows(section: Int, identifier: any HoundDropDownType) -> Int {
        guard let sort = sort else {
            return 0
        }
        guard let type = identifier as? LogsSortDropDownTypes else { return 0 }
        switch type {
        case .sortField:
            return sort.availableFields.count
        case .sortDirection:
            return sort.availableDirections.count
        }
    }
    
    func numberOfSections(identifier: any HoundDropDownType) -> Int {
        guard let type = identifier as? LogsSortDropDownTypes else { return 0 }
        switch type {
        case .sortField, .sortDirection:
            return 1
        }
    }
    
    func selectItemInDropDown(indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let sort = sort else { return }
        guard let type = identifier as? LogsSortDropDownTypes else { return }
        guard let dropDown = dropDownManager.dropDown(for: type) else { return }
        guard let cell = dropDown.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTVC else { return }
        
        switch type {
        case .sortField:
            let type = sort.availableFields[indexPath.row]
            
            // prevent deselection. we shuld always have one selected
            guard type != sort.sortField else {
                return
            }
            
            cell.setCustomSelected(true)
            sort.sortField = type
            dropDown.hideDropDown(animated: true)
        case .sortDirection:
            let type = sort.availableDirections[indexPath.row]
            
            // prevent deselection. we shuld always have one selected
            guard type != sort.sortDirection else {
                return
            }
            
            cell.setCustomSelected(true)
            sort.sortDirection = type
            dropDown.hideDropDown(animated: true)
        }
        updateDynamicUIElements()
    }
    
    func firstSelectedIndexPath(identifier: any HoundDropDownType) -> IndexPath? {
        guard let sort = sort else { return nil }
        guard let type = identifier as? LogsSortDropDownTypes else { return nil }
        switch type {
        case .sortField:
            if let idx = sort.availableFields
                .firstIndex(where: { $0 == sort.sortField }) {
                return IndexPath(row: idx, section: 0)
            }
        case .sortDirection:
            if let idx = sort.availableDirections
                .firstIndex(where: { $0 == sort.sortDirection }) {
                return IndexPath(row: idx, section: 0)
            }
        }
        return nil
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        containerView.addSubview(pageHeaderView)
        
        containerView.addSubview(sortFieldStack)
        
        containerView.addSubview(sortDirectionStack)
        
        containerView.addSubview(applyButton)
        containerView.addSubview(resetButton)
        
        let didTapScreenGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScreen(sender:)))
        didTapScreenGesture.delegate = self
        didTapScreenGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(didTapScreenGesture)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        pageHeaderView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top)
            make.leading.equalTo(containerView.snp.leading)
            make.trailing.equalTo(containerView.snp.trailing)
        }
        
        sortFieldStack.snp.makeConstraints { make in
            make.top.equalTo(pageHeaderView.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.horizontalEdges.equalTo(containerView).inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        sortFieldLabel.snp.makeConstraints { make in
            make.height.equalTo(containerView.snp.width).multipliedBy(Constant.Constraint.Input.textFieldHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
        }
        
        sortDirectionStack.snp.makeConstraints { make in
            make.top.equalTo(sortFieldStack.snp.bottom).offset(Constant.Constraint.Spacing.contentSectionVert)
            make.horizontalEdges.equalTo(containerView).inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        sortDirectionLabel.snp.makeConstraints { make in
            make.height.equalTo(containerView.snp.width).multipliedBy(Constant.Constraint.Input.textFieldHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.textFieldMaxHeight)
        }
        
        applyButton.snp.makeConstraints { make in
            make.top.equalTo(sortDirectionStack.snp.bottom).offset(Constant.Constraint.Spacing.contentSectionVert)
            make.horizontalEdges.equalTo(containerView).inset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.height.equalTo(containerView.snp.width).multipliedBy(Constant.Constraint.Button.wideHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Button.wideMaxHeight)
        }
        
        resetButton.snp.makeConstraints { make in
            make.top.equalTo(applyButton.snp.bottom).offset(Constant.Constraint.Spacing.contentSectionVert)
            make.bottom.equalTo(containerView.snp.bottom).inset(Constant.Constraint.Spacing.absoluteVertInset)
            make.horizontalEdges.equalTo(containerView).inset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.height.equalTo(containerView.snp.width).multipliedBy(Constant.Constraint.Button.wideHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Button.wideMaxHeight)
        }
    }
    
}
