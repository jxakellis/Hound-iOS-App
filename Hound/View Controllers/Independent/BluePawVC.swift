//
//  BluePawVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/24/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class BluePawVC: HoundViewController {

    // MARK: - Elements
    
    private let pawWithHands: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 340, compressionResistancePriority: 340)

        imageView.image = UIImage(named: "whitePawWithHands")
        
        return imageView
    }()
    
    let headerLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 330, compressionResistancePriority: 330)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        label.textColor = .systemBackground
        return label
    }()
    
    let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.tertiaryHeaderLabel
        label.textColor = .secondarySystemBackground
        return label
    }()
    
    let backButton: HoundButton = {
        let button = HoundButton(huggingPriority: 350, compressionResistancePriority: 350)
        
        button.tintColor = .systemBackground
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBlue
        
        button.shouldDismissParentViewController = true
        return button
    }()

    let contentView: HoundView = {
        let view = HoundView(huggingPriority: 310, compressionResistancePriority: 310)
        
        return view
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
        self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
        ? ClassConstant.DogConstant.blackPawWithHands
        : ClassConstant.DogConstant.whitePawWithHands
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
            ? ClassConstant.DogConstant.blackPawWithHands
            : ClassConstant.DogConstant.whitePawWithHands
        }
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBlue
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        view.addSubview(pawWithHands)
        view.addSubview(headerLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(backButton)
        view.addSubview(contentView)
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        // backButton
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ConstraintConstant.Spacing.absoluteMiniCircleInset),
            backButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteMiniCircleInset),
            backButton.createHeightMultiplier(ConstraintConstant.Button.miniCircleHeightMultiplier, relativeToWidthOf: view),
            backButton.createMaxHeight( ConstraintConstant.Button.miniCircleMaxHeight),
            backButton.createSquareAspectRatio()
        ])

        // pawWithHands
        NSLayoutConstraint.activate([
            pawWithHands.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pawWithHands.createSquareAspectRatio(),
            pawWithHands.createHeightMultiplier(ConstraintConstant.Text.pawHeightMultiplier, relativeToWidthOf: view),
            pawWithHands.createMaxHeight(ConstraintConstant.Text.pawMaxHeight)
        ])

        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: pawWithHands.bottomAnchor, constant: 20),
            headerLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])

        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12.5),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])

        // contentView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset)
        ])
    }

}
