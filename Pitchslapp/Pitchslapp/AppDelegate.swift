//
//  AppDelegate.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/28/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import DBChooser
import ZAlertView
import Firebase
import QuartzCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    override init() {
        super.init()
        Firebase.defaultConfig().persistenceEnabled = true
        let mainRef = Firebase(url: "https://popping-inferno-1963.firebaseio.com/")
        mainRef.keepSynced(true)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Override point for customization after application launch.
        UIBarButtonItem.appearance()
            .setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Avenir-Heavy", size: 16.0)!],
                forState: UIControlState.Normal)
                
        // configure ZAlertView
        ZAlertView.showAnimation = .FlyLeft
        ZAlertView.hideAnimation = .FlyRight
        ZAlertView.blurredBackground = true
        ZAlertView.buttonFont = UIFont(name: "Avenir-Heavy", size: 15.0)!
        ZAlertView.messageFont = UIFont(name: "Avenir-Medium", size: 15.0)!
        ZAlertView.alertTitleFont = UIFont(name: "Avenir-Heavy", size: 18.0)!
        ZAlertView.titleColor = UIColor.init(red: 107/255, green: 80/255, blue: 176/255, alpha: 1)
        
        self.window?.layer.cornerRadius = 6.0
        self.window?.layer.masksToBounds = true
        self.window?.layer.opaque = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if !(defaults.boolForKey("HasLaunched")) {
            defaults.setBool(true, forKey: "HasLaunched")
            defaults.setDouble(4.0, forKey: "Octave")
        }
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if (DBChooser.defaultChooser().handleOpenURL(url)) {
            return true
        }
        return false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

