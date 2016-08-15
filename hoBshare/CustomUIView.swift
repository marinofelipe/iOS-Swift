//
//  CustomUIView.swift
//  hoBshare
//
//  Created by Felipe Lefevre Marino on 14/08/16.
//  Copyright © 2016 Felipe Lefevre Marino. All rights reserved.
//

import UIKit

@IBDesignable class CustomUIView: UIView {
    
    
    @IBInspectable var viewBackgroundColor: UIColor? {
        didSet {
            layer.backgroundColor = viewBackgroundColor?.CGColor
            layer.cornerRadius = 8
        }
    }
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.center.x - 4.0, self.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.center.x + 4.0, self.center.y))
        layer.addAnimation(animation, forKey: "position")
    }
    
}
