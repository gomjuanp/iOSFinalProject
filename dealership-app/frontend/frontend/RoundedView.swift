//
//  RoundedView.swift
//  frontend
//
//  Created by Daniel Bajenov on 2026-03-30.
//

import UIKit

class RoundedView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
    }

}
