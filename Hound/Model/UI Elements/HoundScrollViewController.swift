//
//  HoundScrollViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/30/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HoundScrollViewController: HoundViewController {
    
    // MARK: - Elements
    
    private let scrollView: HoundScrollView = {
        let scrollView = HoundScrollView()
        scrollView.onlyScrollIfBigger()
        // Disable automatic adjustments so contentInset.top can be manually
        // managed without the system adding an additional safe area inset.
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    let containerView: HoundView = HoundView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setupConstraints()
    }
    
    // MARK: - Safe Area Update
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // This will ensure at rest, your content starts at safe area, but can scroll behind
        scrollView.contentInset.top = view.safeAreaInsets.top
        scrollView.verticalScrollIndicatorInsets.top = view.safeAreaInsets.top
    }
    
    // MARK: - Setup
    
    override func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
    }
    
    override func setupConstraints() {
        // scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
}
