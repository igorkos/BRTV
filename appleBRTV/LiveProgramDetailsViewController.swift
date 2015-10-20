//
//  LiveProgramDetailsViewController.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/17/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

class LiveProgramDetailsViewController: UIViewController {
    @IBOutlet var channelImage : UIImageView! = nil
    @IBOutlet var programName : UILabel! = nil
    @IBOutlet var programTime : UILabel! = nil
    @IBOutlet var programImage : UIImageView! = nil
    @IBOutlet var programDescription : UITextView! = nil
    
    
    var imageType = 1
    var programData: TVGridProgram? = nil
    
    override func viewDidLoad() {
        self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 520)
        if programData != nil {
            programName?.text = programData![.name] as? String
            programDescription?.text = programData![.description] as? String
            BRTVAPI.sharedInstance.getImageURIs(programData![.channelID] as! Int, mediaType: BRTVAPIImageType.ChanelLogoOriginal, index: 1, completion: {(response: AnyObject?, error: NSError?) in
                let imageURL = NSURL(string: response as! String)!
                self.channelImage!.load(imageURL)
            })
            
            if (programData![.imageCount] as? Int) >= 1 {
                BRTVAPI.sharedInstance.getImageURIs(programData![.id] as! Int, mediaType: BRTVAPIImageType.TVProgramEPG, index: 1, completion: {(response: AnyObject?, error: NSError?) in
                    let imageURL = NSURL(string: response as! String)!
                    self.programImage!.load(imageURL)
                })
            }
            else{
                BRTVAPI.sharedInstance.getImageURIs(programData![.id] as! Int, mediaType: BRTVAPIImageType.DefaultImage, index: 1, completion: {(response: AnyObject?, error: NSError?) in
                    let imageURL = NSURL(string: response as! String)!
                    self.programImage!.load(imageURL)
                })
            }
            self.programImage?.image = nil
            programTime.text = "\(programData!.startTime().toShortTimeString()) : \(programData!.endTime().toShortTimeString())"
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch  segue.identifier! {
        case "LiveChanelPlay":
            let itemID = programData![.channelID] as? Int
            let dest = segue.destinationViewController as! VideoPlayer
            dest.itemID = itemID
        default:
            break
        }
    }
}
