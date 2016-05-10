//
//  InputCirclesView.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/9/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit

class InputCirclesView: UIView {
    let passcodeLength: Int
    init(passcodeLength: Int) {
        precondition(passcodeLength > 0, "Passcode's length should be positive")
        
        self.passcodeLength = passcodeLength
        
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        fatalError("Call init(passcodeLength:) instead")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
