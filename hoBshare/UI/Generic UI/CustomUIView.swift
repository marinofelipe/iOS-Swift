//
//  CustomUIView.swift
//  hoBshare
//
//  Created by Felipe Lefevre Marino on 14/08/16.
//  Copyright © 2016 Felipe Lefevre Marino. All rights reserved.
//

import UIKit

@IBDesignable class CustomUIView: UIView, Shakeable {
    
    
    @IBInspectable var viewBackgroundColor: UIColor? {
        didSet {
            layer.backgroundColor = viewBackgroundColor?.CGColor
            layer.cornerRadius = 8
        }
    }
    
}
