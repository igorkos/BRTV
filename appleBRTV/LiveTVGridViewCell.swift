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
    var programData: TVGridProgram? = nil
    
    override func layoutSubviews(){
        super.layoutSubviews()
        if programData != nil {
            title?.text = programData![.name] as? String
        }
    }
}

class LiveTVTimeGridViewCell: UICollectionViewCell {
    @IBOutlet var title : UILabel? = nil
}
