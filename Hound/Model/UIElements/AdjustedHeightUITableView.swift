//
//  AutomaticHeightUITableView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/17/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class AutomaticHeightUITableView: UITableView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}