//
//  MainTabBar.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class MainTabBar: UITabBar {

    // MARK: - Properties

    private var shapeLayer: CAShapeLayer?
    private let radii: Double = Constant.Visual.Layer.imageCoveringViewCornerRadius

    // MARK: - Main

    override func draw(_ rect: CGRect) {
        addShape()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.isTranslucent = true
        self.layer.cornerRadius = Constant.Visual.Layer.imageCoveringViewCornerRadius
        self.layer.cornerCurve = .continuous
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // UI has changed its appearance to dark/light mode
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // same as addShape
            shapeLayer?.strokeColor = UIColor.systemGray4.cgColor
            shapeLayer?.fillColor = UIColor.systemBackground.cgColor
            shapeLayer?.shadowColor = UIColor.systemGray4.cgColor
        }
    }

    // MARK: - Functions

    private func addShape() {
        let shapeLayer = CAShapeLayer()

        shapeLayer.path = {
            UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: radii, height: 0.0)
            ).cgPath
        }()
        // same as traitCollectionDidChange
        shapeLayer.strokeColor = UIColor.systemGray4.cgColor
        shapeLayer.fillColor = UIColor.systemBackground.cgColor
        shapeLayer.shadowColor = UIColor.systemGray4.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.shadowOffset = CGSize(width: 0, height: -2)
        shapeLayer.shadowOpacity = 0.1
        shapeLayer.shadowRadius = 8
        shapeLayer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radii).cgPath

        if let oldShapeLayer = self.shapeLayer {
            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        }
        else {
            layer.insertSublayer(shapeLayer, at: 0)
        }

        self.shapeLayer = shapeLayer
    }

}
