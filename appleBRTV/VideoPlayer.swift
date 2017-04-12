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
    var itemURL: URL? = nil
    var contentType : MediaContentType = .live
    
    override func viewDidLoad() {
        
        assert(itemID != nil, "Item id is nil")
        print("item id: \(itemID)")
        
            BRTVAPI.sharedInstance.getStreamURI(itemID!, type: contentType, completion: { (response: AnyObject?, error: Error?) in
                guard let result = response as? Dictionary<String,AnyObject> else {
                    return
                }
                let urlStr = result["URL"] as! String
                let url = URL(string: urlStr)!
                print("did get url: \(url)")
                self.player = AVPlayer(url: url)
                self.player?.play()
            })
        
        
        
    }
    
}
