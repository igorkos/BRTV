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
    var contentType : MediaContentType = .live
    
    override func viewDidLoad() {
        self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 520)
        if program != nil {
            programName?.text = program!.name
            programDescription?.text = program!.description
            BRTVAPI.sharedInstance.getImageURIs(program!.channelID, mediaType: BRTVAPIImageType.chanelLogoOriginal, index: 1, completion: {(response: AnyObject?, error: Error?) in
                let imageURL = URL(string: response as! String)!
                self.channelImage!.loadImage(imageURL)
            })
            
            if program!.imageCount >= 1 {
                BRTVAPI.sharedInstance.getImageURIs(program!.id, mediaType: BRTVAPIImageType.tvProgramEPG, index: 1, completion: {(response: AnyObject?, error: Error?) in
                    let imageURL = URL(string: response as! String)!
                    self.programImage!.loadImage(imageURL)
                })
            }
            else{
                BRTVAPI.sharedInstance.getImageURIs(program!.id, mediaType: BRTVAPIImageType.defaultImage, index: 1, completion: {(response: AnyObject?, error: Error?) in
                    let imageURL = URL(string: response as! String)!
                    self.programImage!.loadImage(imageURL)
                })
            }
            self.programImage?.image = nil
            programTime.text = "\(program!.startTime.toShortString()) : \(program!.endTime.toShortString())"
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch  segue.identifier! {
        case "LiveChanelPlay":
            let dest = segue.destination as! VideoPlayer
            dest.contentType = contentType
            switch contentType {
            case .live:
                dest.itemID = program!.channelID
            case .archive:
                dest.itemID = program!.id
            }
            
        default:
            break
        }
    }
}
