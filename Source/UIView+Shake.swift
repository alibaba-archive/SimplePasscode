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
    func shake(needsVibration: Bool, completion: (() -> Void)?) {
        if needsVibration {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
            let xOffsets: [CGFloat] = [0, 25, -20, 15, -10, 5, 0]
            let frameDuration = 1.0 / Double(xOffsets.count)
            
            for i in 0..<xOffsets.count {
                UIView.addKeyframe(withRelativeStartTime: Double(i) * frameDuration, relativeDuration: frameDuration, animations: {
                    self.transform = CGAffineTransform(translationX: xOffsets[i], y: 0)
                })
            }
        }) { finished in
            if finished {
                completion?()
            }
        }
    }
}
