//
//  LiveTVCollectionViewController.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/2/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ProgramItem"
private let reuseTimeIdentifier = "TimeGridItem"
private let reuseChannelIdentifier = "ChannelIcon"

class LiveTVCollectionViewController: UICollectionViewController , UICollectionViewDelegateFlowLayout, TVGridDataSourceDelegate{

    var tvGrid: TVGridDataSource = TVGridDataSource.sharedInstance
    var minuteWidth : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let size = self.collectionView?.frame.size
        minuteWidth = (size?.width)! / (8*30)
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "updateData", name:NotificationUpdateLayoutData, object: nil)
        collectionView!.remembersLastFocusedIndexPath = true
        
        tvGrid.delegate = self
        tvGrid.reloadGrid()        
    }
    
    override func viewWillAppear(animated: Bool){
         tvGrid.updateGrid()
    }
    
    // MARK: - Navigation
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch  segue.identifier! {
        case "ShowProgramDetails":
            let dest = segue.destinationViewController as! LiveProgramDetailsViewController
            let cell = sender as! LiveTVGridViewCell
            dest.program = cell.programData
            dest.contentType = .Live
            let popOverPresentationController = segue.destinationViewController.popoverPresentationController
            let index = NSIndexPath(forItem: 0, inSection: cell.indexPath!.section)
            let view = collectionView?.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: index)
            popOverPresentationController!.sourceRect  = view!.frame
            popOverPresentationController!.sourceView  = collectionView
        default: break
            
        }
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return tvGrid.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return  1000
        }
        let channel = tvGrid[section]
        return channel!.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseTimeIdentifier, forIndexPath: indexPath) as! LiveTVTimeGridViewCell
            let cellTime  = tvGrid.tvGridStartTime + (indexPath.item*30*60)
            cell.title?.text = cellTime.toShortString()
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LiveTVGridViewCell
            let channel = tvGrid[indexPath.section]
            cell.programData = channel![indexPath.item]
            cell.indexPath = indexPath
            return cell
        }
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseChannelIdentifier, forIndexPath: indexPath) as! LiveTVGridChannelIconView
        let channel = tvGrid[indexPath.section]
        Functions.loadImage(channel!.id, mediaType: BRTVAPIImageType.ChanelLogoOriginal, index: 1, imageView: cell.icon!)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool{
        return true
    }
    
    override func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool{
        return true
    }
    
    override func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator){
        if context.previouslyFocusedIndexPath != nil {
            let cell = collectionView.cellForItemAtIndexPath(context.previouslyFocusedIndexPath!)
            switch cell {
            case is LiveTVGridViewCell:
                cell!.backgroundColor = UIColor.whiteColor()
            case is LiveTVTimeGridViewCell:
                cell!.backgroundColor = UIColor.darkGrayColor()
            default:
                break
            }

        }
        if context.nextFocusedIndexPath != nil {
            let  cell = collectionView.cellForItemAtIndexPath(context.nextFocusedIndexPath!)
            switch cell {
            case is LiveTVGridViewCell:
                cell!.backgroundColor = UIColor.grayColor()
            case is LiveTVTimeGridViewCell:
                cell!.backgroundColor = UIColor.grayColor()
            default:
                break
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if cell is  LiveTVGridViewCell {
            performSegueWithIdentifier("ShowProgramDetails", sender: cell)
        }
    }

    
    // MARK: - UICollectionViewFlowLayout
    
    func randomNumber(range: Range<Int> = 1...6) -> Int {
        let min = range.startIndex
        let max = range.endIndex
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 0 {
            var size = self.collectionView?.frame.size
            size?.height = 50
            size?.width = minuteWidth * 30
            return size!
        }
        
        let channel = tvGrid[indexPath.section]
        let program = channel![indexPath.item]
        var lenght = program!.length
        if tvGrid.tvGridStartTime > program!.startTime {
            lenght = (program!.endTime - tvGrid.tvGridStartTime)/Duration(60)
        }
        let width = minuteWidth*CGFloat(lenght)
        // print("sizeForItem -> width=\(lenght)")
        return CGSizeMake(width, 120)
   }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake( 120, 120)
    }
    
    //MARK: - TVGridDataSourceDelegate
    var spinner : SwiftSpinner?
    func tvGridDataSource(tvGridDataSource: TVGridDataSource, didChangeObjects: NSRange){
    }
    func controllerWillChangeContent(tvGridDataSource: TVGridDataSource ){
        spinner = SwiftSpinner.show("Loading TV Programs...",toView: self.view)
    }
    func controllerDidChangeContent(tvGridDataSource: TVGridDataSource ){
        (collectionView?.collectionViewLayout as! InfiniteHorizontalLayout).maxWith = 0
        collectionView?.reloadData()
        spinner?.hide()
    }
    func tvGridDataSource(tvGridDataSource: TVGridDataSource, didGetError: ErrorType){
        
    }

    
}
