//
//  HoundScrollViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/30/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

enum HoundScrollViewDetent: CaseIterable {
    case third
    case medium
    case large
    
    fileprivate var identifier: UISheetPresentationController.Detent.Identifier {
        switch self {
        case .third:
            return .third
        case .medium:
            return .medium
        case .large:
            return .large
        }
    }
    
    fileprivate var detent: UISheetPresentationController.Detent {
        if #available(iOS 16.0, *) {
            switch self {
            case .third:
                return .custom(identifier: .third) { context in
                    context.maximumDetentValue * 0.33
                }
            case .medium:
                return .medium()
            case .large:
                return .large()
            }
        }
        else {
            switch self {
            case .third:
                return .medium()
            case .medium:
                return .medium()
            case .large:
                return .large()
            }
        }
    }
}

extension UISheetPresentationController.Detent.Identifier {
    static let third = UISheetPresentationController.Detent.Identifier("third")
}

class HoundScrollViewController: HoundViewController {
    
    // MARK: - Elements
    
    let scrollView: HoundScrollView = {
        let scrollView = HoundScrollView()
        scrollView.onlyScrollIfBigger()
        // Disable automatic adjustments so contentInset.top can be manually
        // managed without the system adding an additional safe area inset.
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    let containerView: HoundView = HoundView()
    
    // MARK: - Properties
    
    private var detents: [HoundScrollViewDetent] = []
    private var initialDetent: HoundScrollViewDetent?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setupConstraints()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // Set the top content inset so the scroll view's content initially starts just below the safe area (e.g., under the notch or status bar).
        scrollView.contentInset.top = view.safeAreaInsets.top
        scrollView.contentInset.bottom = view.safeAreaInsets.bottom
        // Reset the content offset so the top of the contelont is aligned exactly with the safe area top when the view first appears.
        // This avoids the scroll view appearing already scrolled down due to system adjustments when the inset is changed.
        scrollView.contentOffset.y = -view.safeAreaInsets.top
    }
    
    // MARK: - Setup
    
    func configureDents(
        detents: [HoundScrollViewDetent] = HoundScrollViewDetent.allCases,
        initialDetent: HoundScrollViewDetent
    ) {
        self.detents = detents
        self.initialDetent = initialDetent
        configureDetents()
    }
    
    // MARK: - Functions
    
    func scrollDescendantViewToVisibleIfNeeded(_ targetView: UIView, verticalPadding: CGFloat = Constant.Constraint.Spacing.absoluteVertInset) {
        // Convert the target view's frame to the scrollView's coordinate system
        let targetRect = containerView.convert(targetView.frame, from: targetView.superview)
        let paddedRect = targetRect.insetBy(dx: 0, dy: -verticalPadding)
        
        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        
        if !visibleRect.contains(paddedRect) {
            scrollView.scrollRectToVisible(paddedRect, animated: true)
        }
    }
    
    private func configureDetents() {
        guard let sheet = self.sheetPresentationController else { return }
        guard let initialDetent = initialDetent, !detents.isEmpty else { return }
        sheet.detents = detents.map { $0.detent }
        sheet.selectedDetentIdentifier = initialDetent.identifier
        sheet.prefersGrabberVisible = true
        sheet.prefersScrollingExpandsWhenScrolledToEdge = true
    }
    
    // MARK: - Setup
    
    override func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
    }
    
    override func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.snp.edges)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            make.horizontalEdges.equalTo(scrollView.contentLayoutGuide.snp.horizontalEdges)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
    }
}
