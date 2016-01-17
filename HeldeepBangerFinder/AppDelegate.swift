//
//  AppDelegate.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/9/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//

import UIKit

import Parse
import Bolts
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var player: AVPlayer?
    var nowPlayingId: String?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // MARK: - Parse Setup
        Parse.setApplicationId("IAwGLdS47JrPuxII2gR9BEpJDXF25FEY6jiVCN0s", clientKey: "SvKu7a8mkh6rFycmLJBMWGV3HuTG5VNYYvNfCtSX")
        
        // MARK: - Parse Register Subclasses
        Episode.registerSubclass()
        Track.registerSubclass()
        
        // Track statistics around application opens
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        // Register for remote notifications
        let userNotificationType = UIUserNotificationType.Badge
        let settings = UIUserNotificationSettings(forTypes: userNotificationType, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Override point for customization after application launch.
        
        return true
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
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the device token in the current Installation and save it to Parse
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }

}

func appDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}

