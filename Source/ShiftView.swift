//
//  ShiftView.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import SnapKit

enum ShiftDirection {
    case Forward
    case Backward
}

class ShiftView<T: UIView>: UIView {
    // MARK: - Properties
    let firstView: T
    let secondView: T
    
    private(set) var currentView: T
    
    // MARK: - Initializers
    init(firstView: T, secondView: T) {
        self.firstView = firstView
        self.secondView = secondView
        
        self.currentView = firstView
        
        super.init(frame: .zero)
        
        setup()
    }
    
    override init(frame: CGRect) {
        fatalError("Call self.init(firstView:secondView:) to initialize")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Call self.init(firstView:secondView:) to initialize")
    }
    
    // MARK: - Common Initialization Logic
    private func setup() {
        clipsToBounds = true
        
        addSubview(firstView)
        addSubview(secondView)
        
        firstView.snp_remakeConstraints { make in
            make.edges.equalTo(self)
        }
        
        secondView.snp_remakeConstraints { make in
            make.top.equalTo(self)
            make.left.equalTo(self.snp_right)
            make.bottom.equalTo(self)
            make.width.equalTo(self)
        }
    }
    
    // MARK: - Shift Function
    func shift(direction: ShiftDirection) {
        switch direction {
        case .Forward:
            if currentView == firstView {
                currentView = secondView
                
                UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut], animations: {
                    self.firstView.snp_remakeConstraints { make in
                        make.top.equalTo(self)
                        make.right.equalTo(self.snp_left)
                        make.bottom.equalTo(self)
                        make.width.equalTo(self)
                    }
                    
                    self.secondView.snp_remakeConstraints { make in
                        make.edges.equalTo(self)
                    }
                    
                    self.layoutIfNeeded()
                    }, completion: nil)
            }
        case .Backward:
            if currentView == secondView {
                currentView = firstView
                
                UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut], animations: {
                    self.firstView.snp_remakeConstraints { make in
                        make.edges.equalTo(self)
                    }
                    
                    self.secondView.snp_remakeConstraints { make in
                        make.top.equalTo(self)
                        make.left.equalTo(self.snp_right)
                        make.bottom.equalTo(self)
                        make.width.equalTo(self)
                    }
                    
                    self.layoutIfNeeded()
                    }, completion: nil)
            }
        }
    }
}
