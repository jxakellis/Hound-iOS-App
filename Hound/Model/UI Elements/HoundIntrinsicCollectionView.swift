//
//  HoundIntrinsicCollectionView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class HoundIntrinsicCollectionView: UICollectionView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return contentSize
    }

    override func reloadData() {
        super.reloadData()
        layoutIfNeeded()
        invalidateIntrinsicContentSize()
    }
}
