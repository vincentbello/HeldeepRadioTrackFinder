//
//  NotificationPromptViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 1/14/16.
//  Copyright © 2016 Vincent Bello. All rights reserved.
//

import UIKit
import Parse

class NotificationPromptViewController: UIViewController {
    
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!

    @IBAction func didTapYes(sender: AnyObject) {

        let userNotificationType = UIUserNotificationType.Badge
        let settings = UIUserNotificationSettings(forTypes: userNotificationType, categories: nil)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        setDidAnswerNotificationPrompt()
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func didTapNo(sender: AnyObject) {
        setDidAnswerNotificationPrompt()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        yesButton.layer.borderColor = UIColor.whiteColor().CGColor
        noButton.layer.borderColor = UIColor.whiteColor().CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDidAnswerNotificationPrompt() {
        let installation = PFInstallation.currentInstallation()
        installation["didAnswerNotificationPrompt"] = true
        installation.saveInBackground()
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
