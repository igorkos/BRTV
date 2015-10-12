//
//  SplashScreenViewController.swift
//  appleBRTV
//
//  Created by Aleksandr Kelbas on 12/10/2015.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //check if logged in
        if let credentials = NSURLCredentialStorage.sharedCredentialStorage().credentialsForProtectionSpace(Functions.getUrlProtectionSpace())
        {
            // try login
            let key = credentials.keys.first!
            
            if let cred = credentials[key]
            {
                
                if cred.user != nil && cred.password != nil
                {
                    BRTVAPI.sharedInstance.login(cred.user!, password: cred.password!, completion: {
                        (response: AnyObject?, error: NSError?) in
                        
                        if (error != nil)
                        {
                         
                            NSURLCredentialStorage.sharedCredentialStorage().removeCredential(cred, forProtectionSpace: Functions.getUrlProtectionSpace())
                            self.performSegueWithIdentifier("ShowLogin", sender: self)
                         
                        }
                        else
                        {
                            
                            self.performSegueWithIdentifier("GoToHomePage", sender: self)
                        }

                    })
                }
                
                
            }
            
        }
        else
        {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("ShowLogin", sender: self)
            }
            
        }
        
        
        
      
        
        
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
