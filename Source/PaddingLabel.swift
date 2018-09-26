//
//  PaddingLabel.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/9/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {
    let padding: UIEdgeInsets
    
    init(padding: UIEdgeInsets) {
        self.padding = padding
        super.init(frame: .zero)
    }
    
    convenience override init(frame: CGRect) {
        self.init(padding: UIEdgeInsets.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize : CGSize {
        var contentSize = super.intrinsicContentSize
        
        contentSize.width += padding.left + padding.right
        contentSize.height += padding.top + padding.bottom
        
        return contentSize
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizeToFit = CGSize(width: size.width - padding.left - padding.right, height: size.height - padding.top - padding.bottom)
        
        var targetSize = super.sizeThatFits(sizeToFit)
        
        targetSize.width += padding.left + padding.right
        targetSize.height += padding.top + padding.bottom
        
        return targetSize
    }
}
