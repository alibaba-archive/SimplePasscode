//
//  LockscreenManager.swift
//  SimplePasscode
//
//  Created by Zhu Shengqi on 5/8/16.
//  Copyright © 2016 Zhu Shengqi. All rights reserved.
//

import UIKit

public class LockScreenManager {
    private static var isShowingLockScreen = false
    private static var mainWindow: UIWindow?
    private static var lockWindow: UIWindow?
    
    public static func showLockScreen(passcode passcode: String, completion: (authenticationSuccess: Bool) -> Void) {
        guard !isShowingLockScreen else {
            return
        }
        
        isShowingLockScreen = true
        
        mainWindow = UIApplication.sharedApplication().keyWindow
        mainWindow!.endEditing(true)
        
        lockWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        lockWindow!.windowLevel = mainWindow!.windowLevel + 1
        
        let authenticationViewController = AuthenticationViewController()
        authenticationViewController.currentPasscode = passcode
        authenticationViewController.completionHandler = completion
        lockWindow!.rootViewController = authenticationViewController
        
        lockWindow!.alpha = 0
        lockWindow!.makeKeyAndVisible()
        
        UIView.animateWithDuration(0.1) {
            lockWindow!.alpha = 1
        }
    }
    
    public static func hideLockScreen() {
        guard isShowingLockScreen else {
            return
        }
        
        UIView.animateWithDuration(0.3, animations: { 
            lockWindow!.alpha = 0
            }, completion: { _ in
                mainWindow!.makeKeyAndVisible()
                lockWindow = nil
                mainWindow = nil
                isShowingLockScreen = false
        })
    }
}
