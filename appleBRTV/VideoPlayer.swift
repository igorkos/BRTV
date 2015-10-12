//
//  VideoPlayer.swift
//  appleBRTV
//
//  Created by Aleksandr Kelbas on 11/10/2015.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit
import AVKit

class VideoPlayer: AVPlayerViewController {

    var itemID: Int? = nil
    var itemURL: NSURL? = nil
    
    override func viewDidLoad() {
        
        assert(itemID != nil, "Item id is nil")
        print("item id: \(itemID)")
        if let sessionID = NSUserDefaults.standardUserDefaults().objectForKey("sessionID")
        {
            BRTVAPI.sharedInstance.getStreamURI(itemID!, sessionID: sessionID as! String, completion: { (response: AnyObject?, error: NSError?) in
                
                let urlStr = response!["URL"] as! String
                let url = NSURL(string: urlStr)!
                print("did get url: \(url)")
                self.player = AVPlayer(URL: url)
                self.player?.play()
            })
        
        
        }
        else
        {
            print("no sessionID found")
        }
        
        
    }
    
}
