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
                        [weak self](response: AnyObject?, error: NSError?) in
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            if (error != nil)
                            {
                                NSURLCredentialStorage.sharedCredentialStorage().removeCredential(cred, forProtectionSpace: Functions.getUrlProtectionSpace())
                                self?.presentLoginPage()
                                
                            }
                            else
                            {
                                self?.presentHomePage()
                            }

                        })
                        
                    })
                }
                
                
            }
            
        }
        else
        {
            presentLoginPage()
        }
        
        
    }
    
    func presentLoginPage()
    {
        if let login = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController
        {
            
            login.completion = { [weak self]() in
                
                self?.presentHomePage()
                
            }
            
            self.addChildViewController(login)
            login.view.frame = self.view.bounds
            self.view.addSubview(login.view)
            login.didMoveToParentViewController(self)
            
        }
        else
        {
            print("Failed to instantiate login view controller")
        }

    }
    
    
    func presentHomePage()
    {
        if let home = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController")
        {
            
            self.addChildViewController(home)
            home.view.frame = self.view.bounds
            self.view.addSubview(home.view)
            home.didMoveToParentViewController(self)
        }
        else
        {
            print("Failed to instantiate home view controller")
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
