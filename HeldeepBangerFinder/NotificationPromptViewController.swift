//
//  NotificationPromptViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 1/14/16.
//  Copyright © 2016 Vincent Bello. All rights reserved.
//

import UIKit

class NotificationPromptViewController: UIViewController {

    @IBAction func didTapYes(sender: AnyObject) {
        
        print("will register notifications")

        let userNotificationType = UIUserNotificationType.Badge
        let settings = UIUserNotificationSettings(forTypes: userNotificationType, categories: nil)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func didTapNo(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
