//
//  MainTabBar.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// UI VERIFIED
final class MainTabBar: UITabBar {

    // MARK: - Properties

    private var shapeLayer: CALayer?
    private let radii: Double = VisualConstant.LayerConstant.imageCoveringViewCornerRadius

    // MARK: - Main

    override func draw(_ rect: CGRect) {
        addShape()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.isTranslucent = true
        self.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        self.layer.cornerCurve = .continuous
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
        shapeLayer.strokeColor = UIColor.systemGray4.cgColor
        shapeLayer.fillColor = UIColor.systemBackground.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.shadowColor = UIColor.systemGray4.cgColor
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
