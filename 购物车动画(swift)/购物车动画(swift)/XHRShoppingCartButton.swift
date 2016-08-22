//
//  XHRShoppingCartButton.swift
//  爱蜜蜂
//
//  Created by 胥鸿儒 on 16/8/20.
//  Copyright © 2016年 xuhongru. All rights reserved.
//

import UIKit

class XHRShoppingCartButton: UIButton {
    var shoppingCount : Int64 = 0
        {
        didSet{
            if shoppingCount != 0
            {
                dotLabel.hidden = false
                dotLabel.text = "\(shoppingCount)"
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.textAlignment = NSTextAlignment.Center
        titleLabel?.font = UIFont.systemFontOfSize(10)
        setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        addSubview(dotLabel)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame.size = CGSizeMake(25, 25)
        imageView?.frame.origin.x = (self.frame.size.width - 25) * 0.5
        imageView?.frame.origin.y = 8
        
        titleLabel?.frame.origin.x = 0
        titleLabel?.frame.origin.y = 35
        titleLabel?.frame.size = CGSizeMake(self.frame.size.width, 14)
        dotLabel.bounds = CGRectMake(0, 0, 14, 14)
        dotLabel.center = CGPointMake(CGRectGetMaxX(imageView!.frame), imageView!.frame.origin.y)
    }
    private lazy var dotLabel : XHRDotLable = XHRDotLable()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class XHRDotLable: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = UIColor.orangeColor()
        textAlignment = NSTextAlignment.Center
        font = UIFont.systemFontOfSize(12)
        hidden = true
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}