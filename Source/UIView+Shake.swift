//
//  UIView+Shake.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/7/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit
import AudioToolbox

extension UIView {
    func shake(needsVibration needsVibration: Bool, completion: (() -> Void)?) {
        if needsVibration {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: [], animations: {
            let xOffsets: [CGFloat] = [0, 10, -8, 8, -5, 5, 0]
            let frameDuration = 1.0 / Double(xOffsets.count)
            
            for i in 0..<xOffsets.count {
                UIView.addKeyframeWithRelativeStartTime(Double(i) * frameDuration, relativeDuration: frameDuration, animations: {
                    self.transform = CGAffineTransformMakeTranslation(xOffsets[i], 0)
                })
            }
        }) { finished in
            if finished {
                completion?()
            }
        }
    }
}