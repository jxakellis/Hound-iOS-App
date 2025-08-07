//
//  LogLikesVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/7/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

final class LogLikesVC: HoundScrollViewController {
    
    // MARK: - Elements
    
    private lazy var pageHeaderView: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView()
        view.pageHeaderLabel.text = "Likes"
        return view
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
        
        self.configureDents(detents: [.third, .large], initialDetent: .third)
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        containerView.addSubview(pageHeaderView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        pageHeaderView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top)
            make.bottom.equalTo(containerView.snp.bottom)
            make.leading.equalTo(containerView.snp.leading)
            make.trailing.equalTo(containerView.snp.trailing)
        }
    }
    
}
