//
//  NumPadView.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/10/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import SnapKit

protocol NumPadViewDelegate {
    func numPadView(_ view: NumPadView, didTapDigit digit: Int)
}

open class NumPadView: UIView {
    // MARK: - Private Properties
    fileprivate var rowContainerViews: [UIView] = []
    fileprivate var horizPadding: CGFloat {
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            return 24
        } else {
            return 20
        }
    }
    
    fileprivate var vertPadding: CGFloat {
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            return 19
        } else {
            return 13
        }
    }
    
    // MARK: - Public Properties
    var delegate: NumPadViewDelegate?
    
    // MARK: - Init & Deinit
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    // MARK: - UI Config
    fileprivate func setupUI() {
        // Layout digits 0 through 8
        for i in 0..<4 {
            let rowContainerView = UIView()
            rowContainerViews.append(rowContainerView)
            
            addSubview(rowContainerView)
            rowContainerView.snp.makeConstraints { make in
                if i == 0 {
                    make.top.equalTo(self)
                } else {
                    make.top.equalTo(rowContainerViews[i - 1].snp.bottom).offset(vertPadding)
                }
                
                if i == 3 {
                    make.centerX.equalTo(self)
                    make.bottom.equalTo(self)
                } else {
                    make.left.equalTo(self)
                    make.right.equalTo(self)
                }
            }
            
            var digitRange: CountableRange<Int>
            if i < 3 {
                digitRange = (3 * i + 1)..<(3 * i + 4) // (1, 2, 3), (4, 5, 6), (7, 8, 9)
            } else {
                digitRange = 0..<1
            }
            
            var previousButton: DigitButton!
            
            for j in digitRange {
                let digitButton = DigitButton(digit: j)
                rowContainerView.addSubview(digitButton)
                
                digitButton.snp.makeConstraints { make in
                    if j == digitRange.startIndex {
                        make.left.equalTo(rowContainerView)
                        make.top.equalTo(rowContainerView)
                        make.bottom.equalTo(rowContainerView)
                    } else {
                        make.left.equalTo(previousButton.snp.right).offset(horizPadding)
                        make.top.equalTo(previousButton)
                        make.bottom.equalTo(previousButton)
                    }
                    
                    if j == digitRange.index(before: digitRange.endIndex) {
                        make.right.equalTo(rowContainerView)
                    }
                }
                
                digitButton.addTarget(self, action: #selector(self.digitButtonTapped(_:)), for: .touchUpInside)
                
                previousButton = digitButton
            }
        }
    }
    
    // MARK: - Action Handlers
    func digitButtonTapped(_ digitButton: DigitButton) {
        delegate?.numPadView(self, didTapDigit: digitButton.digit)
    }
}
