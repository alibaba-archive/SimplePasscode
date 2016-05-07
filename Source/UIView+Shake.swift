//
//  UIView+Shake.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/7/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit

public extension UIView {
    func shake(needsVibration needsVibration: Bool, completion: () -> Void) {
        UIView.animateKeyframesWithDuration(0.5, delay: 0, options: [], animations: {
            let horizOffsets: [CGFloat] = [0, 10, -8, 8, -5, 5, 0]
            let frameDuration = 1.0 / Double(horizOffsets.count)
            
            for i in 0..<horizOffsets.count {
                UIView.addKeyframeWithRelativeStartTime(Double(i) * frameDuration, relativeDuration: frameDuration, animations: {
                    self.transform = CGAffineTransformMakeTranslation(horizOffsets[i], 0)
                })
            }
        }) { finished in
            if finished {
                completion()
            }
        }
    }
}