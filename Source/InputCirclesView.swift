//
//  InputCirclesView.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/9/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import SnapKit

class InputCirclesView: UIView {
    // MARK: - Properties
    let passcodeLength: Int
    
    fileprivate var circleViews: [CircleView] = []
    
    // MARK: - Init & Deinit
    init(passcodeLength: Int) {
        precondition(passcodeLength > 0, "Passcode's length should be positive")
        
        self.passcodeLength = passcodeLength
        
        super.init(frame: .zero)
        
        setupUI()
    }
    
    override init(frame: CGRect) {
        fatalError("Call init(passcodeLength:) instead")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Config
    fileprivate func setupUI() {        
        for i in 0..<passcodeLength {
            let circleView = CircleView()
            addSubview(circleView)
            circleViews.append(circleView)
            
            circleView.snp_makeConstraints { make in
                if i == 0 {
                    make.left.equalTo(self)
                    make.top.equalTo(self)
                    make.bottom.equalTo(self)
                } else {
                    make.left.equalTo(circleViews[i - 1].snp_right).offset(2 * circleView.diameter)
                    make.centerY.equalTo(self)
                }
                
                if i == passcodeLength - 1 {
                    make.right.equalTo(self)
                }
            }
        }
    }
    
    func setFilled(_ filled: Bool, atIndex index: Int) {
        precondition((0..<passcodeLength).contains(index), "index should be non-negative and less than passcodeLength")
        
        circleViews[index].filled = filled
    }
    
    func unfillAllCircles() {
        for view in circleViews {
            view.filled = false
        }
    }
}
