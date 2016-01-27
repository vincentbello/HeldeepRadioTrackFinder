//
//  NotificationManager.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 1/21/16.
//  Copyright © 2016 Vincent Bello. All rights reserved.
//

import UIKit

class NotificationManager: NSObject {
    
    var enabled = false
    var application = UIApplication.sharedApplication()
    
    override init() {
        
        if application.respondsToSelector(Selector("isRegisteredForRemoteNotifications")) {
            enabled = application.isRegisteredForRemoteNotifications()
        }
    }
    
}
