//
//  LiveTVGridViewCell.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/15/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

class LiveTVGridViewCell: UICollectionViewCell {
    @IBOutlet var title : UILabel? = nil
    @IBOutlet var subtitle : UILabel? = nil
    var programData: TVGridProgram? = nil
    var indexPath : NSIndexPath? = nil;
    override func layoutSubviews(){
        super.layoutSubviews()
        if programData != nil {
            title?.text = programData!.name
            subtitle?.text = programData!.formatedShowTime()
        }
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        self.backgroundColor = UIColor.whiteColor()
    }
}

class LiveTVTimeGridViewCell: UICollectionViewCell {
    @IBOutlet var title : UILabel? = nil
    override func layoutSubviews(){
        super.layoutSubviews()
        superview!.bringSubviewToFront(self)
    }
}

class LiveTVGridChannelIconView: UICollectionReusableView {
    @IBOutlet var icon : UIImageView? = nil
    override func layoutSubviews(){
        super.layoutSubviews()
        superview!.bringSubviewToFront(self)
    }
}
