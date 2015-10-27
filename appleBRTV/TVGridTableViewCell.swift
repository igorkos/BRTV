//
//  TVGridTableViewCell.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/14/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

class TVGridTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,TVGridChannelDelegte {

    weak var controller : ChannelsTableViewController? = nil
    var selectedProgramm :TVGridProgram? = nil
    var currentIndex : Int = 0
    
    var minWidth : CGFloat = 0.0
    
    @IBOutlet var collectionView : UICollectionView?
    @IBOutlet var channelIcon : UIImageView?
    @IBOutlet var channelId : UILabel?
    @IBOutlet var sequeAnchor : UIButton!
    
    
    var channelData: TVGridChannel? = nil {
        didSet{
            print("channelData:didSet -> (\(channelData!.id)) programs=\(channelData!.count)")
            channelData?.delegate = self
            collectionView?.reloadData()
        }
    }
    
    override func prepareForReuse(){
        if channelData != nil {
            channelData?.delegate = nil
        }
        super.prepareForReuse()
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        let offset = controller!.timeGridOffset()
        print("TVGridTableViewCell -> search index for time \(offset.toTimeString())")
        let pr = channelData?.programLive(offset)
        currentIndex = 0
        if pr != nil {
            currentIndex = (channelData?.indexOfProgram(pr!))!
        }
        collectionView!.remembersLastFocusedIndexPath = true
        minWidth = 7.0//((self.collectionView?.frame.width)!/CGFloat(240.0))
        channelId?.text = "\(channelData!.accessNum)"
        Functions.loadImage(channelData!.id, mediaType: BRTVAPIImageType.ChanelLogoOriginal, index: 1, imageView: channelIcon!)

    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
    }

    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return (channelData?.count)!
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProgramItem", forIndexPath: indexPath) as! LiveTVGridViewCell
        cell.programData = channelData![indexPath.row]
        let lastIndex = (channelData?.count)! - 1
        if indexPath.row == lastIndex{
            self.controller?.requestGrid( (channelData![lastIndex]?.endTime)!)
        }
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
        return NSIndexPath(forItem: currentIndex, inSection: 0)
    }

    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let program = channelData![indexPath.row]
        var lenght = Float(program!.length)
        if indexPath.row == 0 {
            let startTime = program!.startTime
            let offset : Float = Float(NSDate().closestTo(30).timeIntervalSinceDate(startTime)/60)
            if lenght - offset > 0 {
                lenght = lenght - offset
            }
        }
        let width = minWidth*CGFloat(lenght) - 2
       // print("sizeForItem -> width=\(lenght)")
        return CGSizeMake(width, 120)
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
     //let width = ((self.collectionView?.frame.width)!/240.0) //On minute size
        let offset = scrollView.contentOffset.x///width //ofset in min
        controller?.offsetTimeTable(offset)
    }
    
    // MARK: - TVGridChannelDelegte
    func tvGridChannel(tvGridChannel: TVGridChannel, didAddObjects: NSRange){
        var paths : [NSIndexPath] = []
        for var i = 0 ; i < didAddObjects.length ;i++ {
            paths.append(NSIndexPath(forItem: didAddObjects.location + i, inSection: 0))
        }
        collectionView?.performBatchUpdates( {self.collectionView?.insertItemsAtIndexPaths(paths)}, completion: nil)
    }
    func tvGridChannel(tvGridChannel: TVGridChannel, didRemoveObjects: NSRange){
        
    }
}
