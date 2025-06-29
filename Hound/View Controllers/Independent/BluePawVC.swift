//
//  BluePawVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/24/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

// UI VERIFIED 6/24/25
class BluePawVC: GeneralUIViewController {

    // MARK: - Elements
    
    private let pawWithHands: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 340, compressionResistancePriority: 340)

        imageView.image = UIImage(named: "whitePawWithHands")
        
        return imageView
    }()
    
    let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 330, compressionResistancePriority: 330)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        label.textColor = .systemBackground
        return label
    }()
    
    let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.textColor = .secondarySystemBackground
        return label
    }()
    
    let backButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 350, compressionResistancePriority: 350)
        
        button.tintColor = .systemBackground
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBlue
        
        button.shouldDismissParentViewController = true
        return button
    }()

    let contentView: GeneralUIView = {
        let view = GeneralUIView(huggingPriority: 310, compressionResistancePriority: 310)
        
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
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ConstraintConstant.Spacing.miniCircleAbsInset),
            backButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.miniCircleAbsInset),
            backButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: ConstraintConstant.Button.miniCircleHeightMultiplier).withPriority(.defaultHigh),
            backButton.createMaxHeight( ConstraintConstant.Button.miniCircleMaxHeight),
            backButton.createSquareAspectRatio()
        ])

        // pawWithHands
        NSLayoutConstraint.activate([
            pawWithHands.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pawWithHands.createSquareAspectRatio(),
            pawWithHands.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4).withPriority(.defaultHigh),
            pawWithHands.createMaxHeight( ConstraintConstant.Button.wideMaxHeight * 3.0)
        ])

        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: pawWithHands.bottomAnchor, constant: 20),
            headerLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)
        ])

        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12.5),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)
        ])

        // contentView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintConstant.Spacing.contentAbsVertInset)
        ])
    }

}
