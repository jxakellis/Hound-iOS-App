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
        
        scrollView.onlyBounceIfBigger()
        
        return scrollView
    }()
    
    private var containerViewTopConstraint: GeneralLayoutConstraint!
    let containerView: HoundView = {
        let view = HoundView()
        
        return view
    }()
    
    // MARK: - Main
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // Update top offset to always match safe area
        containerViewTopConstraint.constant = view.safeAreaInsets.top
    }

    // MARK: - Setup Elements

    override func addSubViews() {
        super.addSubViews()
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
    }

    override func setupConstraints() {
        super.setupConstraints()

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        containerViewTopConstraint = GeneralLayoutConstraint(containerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: view.safeAreaInsets.top))
        NSLayoutConstraint.activate([
            containerViewTopConstraint.constraint,
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
}
