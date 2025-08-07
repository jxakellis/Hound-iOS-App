//
//  LogLikesVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/7/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

final class LogLikesVC: HoundScrollViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Elements
    
    private lazy var pageHeaderView: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView()
        view.pageHeaderLabel.text = "Likes"
        return view
    }()
    
    private lazy var likesTableView: HoundTableView = {
        let tableView = HoundTableView(style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LogLikesTVC.self, forCellReuseIdentifier: LogLikesTVC.reuseIdentifier)
        
        tableView.isScrollEnabled = false
        tableView.shouldAutomaticallyAdjustHeight = true
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.emptyStateEnabled = true
        tableView.emptyStateMessage = "No one has liked this log...."
        
        return tableView
    }()
    
    // MARK: - Properties
    
    private var likedDisplayNames: [String] = []
    
    private var log: Log? {
        didSet {
            updateLikedDisplayNames()
            likesTableView.reloadData()
        }
    }
    
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
        
        self.configureDents(detents: [.third, .large], initialDetent: .third)
    }
    
    // MARK: - Setup
    
    func setup(log: Log) {
        self.log = log
    }
    
    // MARK: - Functions
    
    private func updateLikedDisplayNames() {
        guard let log = log else {
            likedDisplayNames = []
            return
        }
        
        likedDisplayNames = log.likedByUserIds.map { userId in
            FamilyInformation.findFamilyMember(userId: userId)?.displayFullName ?? Constant.Visual.Text.unknownName
        }.sorted { lhs, rhs in
            lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedDisplayNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LogLikesTVC.reuseIdentifier, for: indexPath) as? LogLikesTVC else {
            return UITableViewCell()
        }
        cell.setup(displayFullName: likedDisplayNames[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        containerView.addSubview(pageHeaderView)
        containerView.addSubview(likesTableView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        pageHeaderView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top)
            make.leading.equalTo(containerView.snp.leading)
            make.trailing.equalTo(containerView.snp.trailing)
        }
        
        likesTableView.snp.makeConstraints { make in
            make.top.equalTo(pageHeaderView.snp.bottom).offset(Constant.Constraint.Spacing.contentTallIntraVert)
            make.leading.equalTo(containerView.snp.leading)
            make.trailing.equalTo(containerView.snp.trailing)
            make.bottom.equalTo(containerView.snp.bottom)
        }
    }
    
}
