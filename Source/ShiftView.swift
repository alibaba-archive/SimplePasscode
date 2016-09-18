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
    case forward
    case backward
}

class ShiftView<T: UIView>: UIView {
    // MARK: - Properties
    let managedSubViews: [T]
    
    fileprivate(set) var currentView: T
    
    // MARK: - Initializers
    init(managedSubViews: [T]) {
        precondition(managedSubViews.count > 1, "There should be at least 2 managed subviews to shit")
        
        self.managedSubViews = managedSubViews
        self.currentView = self.managedSubViews[0]
        
        super.init(frame: .zero)
        
        setup()
    }
    
    override init(frame: CGRect) {
        fatalError("Call self.init(managedSubViews:) to initialize")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Call self.init(managedSubViews:) to initialize")
    }
    
    // MARK: - Common Initialization Logic
    fileprivate func setup() {
        clipsToBounds = true
        
        for view in managedSubViews {
            addSubview(view)
        }
        
        currentView.snp_remakeConstraints { make in
            make.edges.equalTo(self)
        }
        
        var previousView = currentView
        for view in managedSubViews[managedSubViews.indices.suffix(from: (managedSubViews.startIndex + 1))] {
            view.snp_remakeConstraints { make in
                make.top.equalTo(previousView)
                make.bottom.equalTo(previousView)
                make.width.equalTo(previousView)
                make.left.equalTo(previousView.snp_right)
            }
            
            previousView = view
        }
    }
    
    // MARK: - Public Properties
    var currentIndex: Array<T>.Index {
        return managedSubViews.index(of: currentView)!
    }
    
    // MARK: - Shift Function
    func shift(_ direction: ShiftDirection) {
        switch direction {
        case .forward:
            if currentView != managedSubViews.last {
                let currentIndex = managedSubViews.index(of: currentView)!
                let nextView = managedSubViews[(currentIndex + 1)]
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { 
                    self.currentView.snp_remakeConstraints { make in
                        make.top.equalTo(nextView)
                        make.bottom.equalTo(nextView)
                        make.width.equalTo(nextView)
                        make.right.equalTo(nextView.snp_left)
                    }
                    
                    nextView.snp_remakeConstraints { make in
                        make.edges.equalTo(self)
                    }
                    
                    self.layoutIfNeeded()
                    }, completion: { finished in
                        if finished {
                            self.currentView = nextView
                        }
                    })
                }
        case .backward:
            if currentView != managedSubViews.first {
                let currentIndex = managedSubViews.index(of: currentView)!
                let previousView = managedSubViews[(currentIndex - 1)]
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { 
                    self.currentView.snp_remakeConstraints { make in
                        make.top.equalTo(previousView)
                        make.bottom.equalTo(previousView)
                        make.width.equalTo(previousView)
                        make.left.equalTo(previousView.snp_right)
                    }
                    
                    previousView.snp_remakeConstraints { make in
                        make.edges.equalTo(self)
                    }
                    
                    self.layoutIfNeeded()
                    }, completion: { finished in
                        self.currentView = previousView
                    })
            }
        }
    }
}
