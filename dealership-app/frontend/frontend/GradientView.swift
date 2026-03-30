//
//  GradientView.swift
//  frontend
//
//  Created by Daniel Bajenov on 2026-03-29.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    @IBInspectable var topColor: UIColor = .white
    @IBInspectable var bottomColor: UIColor = .black

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
