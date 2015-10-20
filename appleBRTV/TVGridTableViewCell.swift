//
//  TVGridTableViewCell.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/14/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

class TVGridTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    weak var controller : ChannelsTableViewController? = nil
    var selectedProgramm :TVGridProgram? = nil
    var currentIndex : Int = 0
    var direction = true
    @IBOutlet var collectionView : UICollectionView?
    @IBOutlet var channelIcon : UIImageView?
    @IBOutlet var channelId : UILabel?
    @IBOutlet var sequeAnchor : UIButton!

    var channelData: TVGridChannel? = nil {
        didSet{
            channelId?.text = "\(channelData![.accessNum] as! Int)"
            BRTVAPI.sharedInstance.loadImage(channelData![.id] as! Int, mediaType: BRTVAPIImageType.ChanelLogoOriginal, index: 1, imageView: channelIcon!)
            collectionView?.reloadData()
        }
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        let index = channelData?.indexOfLiveProgram()
        if index >= 0 {
            currentIndex = index!
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
    }

    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        let count = channelData?[.programs]?.count
        return count != nil ? count! : 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProgramItem", forIndexPath: indexPath) as! LiveTVGridViewCell
        cell.programData = channelData![indexPath.row]
        cell.programData![.channelID] = channelData![.id]
        cell.programData![.UtcOffset] = channelData![.UtcOffset]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! LiveTVGridViewCell
        self.selectedProgramm = cell.programData
        self.controller?.performSegueWithIdentifier("ShowProgramDetails", sender: self)
    }

    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool{
        return true
    }
    
    func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool{
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator){
        var cell : LiveTVGridViewCell
        if context.previouslyFocusedIndexPath != nil {
            cell = collectionView.cellForItemAtIndexPath(context.previouslyFocusedIndexPath!) as! LiveTVGridViewCell
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        if context.nextFocusedIndexPath != nil {
            cell = collectionView.cellForItemAtIndexPath(context.nextFocusedIndexPath!) as! LiveTVGridViewCell
            cell.backgroundColor = UIColor.grayColor()
            let offset = collectionView.contentOffset.x
            self.controller?.offsetTimeTable(offset)
        }
    }
    
    func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath?{
        return NSIndexPath(forItem: 4, inSection: 0)
    }

    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let program = channelData![indexPath.row]
        var lenght = program![.length] as! CGFloat
        var width = ((self.collectionView?.frame.width)!/240.0)
        if currentIndex == indexPath.row {
            let startTime = program?.startTime()
            let offset : Double = NSDate().closestTo(30).timeIntervalSinceDate(startTime!)
            lenght = lenght - CGFloat(offset/60)
        }
        width = width*lenght
        return CGSizeMake(width, 120)
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
     //let width = ((self.collectionView?.frame.width)!/240.0) //On minute size
        let offset = scrollView.contentOffset.x///width //ofset in min
        controller?.offsetTimeTable(offset)
    }
    
}
