//
//  LockscreenManager.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit

open class LockScreenManager {
    fileprivate static var isShowingLockScreen = false
    fileprivate static var mainWindow: UIWindow?
    fileprivate static var lockWindow: UIWindow?
    
    open static func showLockScreen(passcode: String, completion: @escaping (_ authenticationSuccess: Bool) -> Void) {
        guard !isShowingLockScreen else {
            return
        }
        
        isShowingLockScreen = true
        
        mainWindow = UIApplication.shared.keyWindow
        mainWindow!.endEditing(true)
        
        lockWindow = UIWindow(frame: UIScreen.main.bounds)
        lockWindow!.windowLevel = mainWindow!.windowLevel + 1
        
        let authenticationViewController = AuthenticationViewController()
        authenticationViewController.currentPasscode = passcode
        authenticationViewController.completionHandler = completion
        lockWindow!.rootViewController = authenticationViewController
        
        lockWindow!.alpha = 0
        lockWindow!.makeKeyAndVisible()
        
        UIView.animate(withDuration: 0.1, animations: {
            lockWindow!.alpha = 1
        }) 
    }
    
    open static func hideLockScreen() {
        guard isShowingLockScreen else {
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: { 
            lockWindow!.alpha = 0
            }, completion: { _ in
                mainWindow!.makeKeyAndVisible()
                lockWindow = nil
                mainWindow = nil
                isShowingLockScreen = false
        })
    }
}
