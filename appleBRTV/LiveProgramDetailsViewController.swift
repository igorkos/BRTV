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
    var program: TVGridProgram? = nil
    
    override func viewDidLoad() {
        self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 520)
        if program != nil {
            programName?.text = program!.name
            programDescription?.text = program!.description
            BRTVAPI.sharedInstance.getImageURIs(program!.channelID, mediaType: BRTVAPIImageType.ChanelLogoOriginal, index: 1, completion: {(response: AnyObject?, error: ErrorType?) in
                let imageURL = NSURL(string: response as! String)!
                self.channelImage!.loadImage(imageURL)
            })
            
            if program!.imageCount >= 1 {
                BRTVAPI.sharedInstance.getImageURIs(program!.id, mediaType: BRTVAPIImageType.TVProgramEPG, index: 1, completion: {(response: AnyObject?, error: ErrorType?) in
                    let imageURL = NSURL(string: response as! String)!
                    self.programImage!.loadImage(imageURL)
                })
            }
            else{
                BRTVAPI.sharedInstance.getImageURIs(program!.id, mediaType: BRTVAPIImageType.DefaultImage, index: 1, completion: {(response: AnyObject?, error: ErrorType?) in
                    let imageURL = NSURL(string: response as! String)!
                    self.programImage!.loadImage(imageURL)
                })
            }
            self.programImage?.image = nil
            programTime.text = "\(program!.startTime.toShortTimeString()) : \(program!.endTime.toShortTimeString())"
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch  segue.identifier! {
        case "LiveChanelPlay":
            let itemID = program!.channelID
            let dest = segue.destinationViewController as! VideoPlayer
            dest.itemID = itemID
        default:
            break
        }
    }
}
