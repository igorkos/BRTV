//
//  ViewController.swift
//  appleBRTV
//
//  Created by Aleksandr Kelbas on 10/10/2015.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    var sessionID: String? = nil
    
    @IBAction func login(sender: AnyObject) {
        
        BRTVAPI.sharedInstance.login("scapegracer", password: "cinnamon", completion: {
            (response: AnyObject?, error: NSError?) in
            
            self.sessionID = (response!["clientCredentials"]!!["sessionID"] as! String)
            print("did login")
            print("session: \(self.sessionID)")
            
            NSUserDefaults.standardUserDefaults().setObject(self.sessionID, forKey: "sessionID")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            self.performSegueWithIdentifier("ViewChannels", sender: self)
            
        })
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

