////
//  ChannelsTableViewController.swift
//  appleBRTV
//
//  Created by Aleksandr Kelbas on 12/10/2015.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit


class ChannelsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, TVGridDataSourceDelegate {

    var tvGrid: TVGridDataSource = TVGridDataSource()
    var timeCells = 0
    @IBOutlet var timeGrid : UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var popoverAnchor: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Reload grid
        tvGrid.delegate = self
        tvGrid.reloadGrid()
        timeLabel.text = NSDate().toShortTimeString()
        timeCells = 10000
        timeGrid.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func offsetTimeTable( offset: CGFloat ){
        let point = CGPointMake(offset, 0)
        timeGrid.setContentOffset(point, animated: false)
        let cells = tableView.visibleCells as! [TVGridTableViewCell]
        for cell in cells {
            cell.collectionView?.setContentOffset(point, animated: false)            
        }
    }
    
    func requestGrid( startTime: NSDate ){
        tvGrid.updateGrid(startTime)
    }
    
    func timeGridOffset() -> NSDate{
        let cells = timeGrid.indexPathsForVisibleItems()
        let result = cells.sort({
            if $0.row < $1.row  {
                return true
            }
            return false
        })
        print("timeGridOffset -> \(result)")
        return tvGrid.tvGridStartTime.dateByAddingTimeInterval(Double(result[0].row*30*60) )
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return tvGrid.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChannelScrollCell", forIndexPath: indexPath) as! TVGridTableViewCell

        cell.channelData = tvGrid[indexPath.section]
        cell.controller = self
        return cell
    }
    
    func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return false
    }
    
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator){
        var cell : TVGridTableViewCell
        if context.previouslyFocusedIndexPath != nil {
            cell = tableView.cellForRowAtIndexPath(context.previouslyFocusedIndexPath!) as! TVGridTableViewCell
            cell.backgroundColor = UIColor.clearColor()
        }
        
        if context.nextFocusedIndexPath != nil {
            cell = tableView.cellForRowAtIndexPath(context.nextFocusedIndexPath!) as! TVGridTableViewCell
            cell.backgroundColor = UIColor.whiteColor()
        }

    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch  segue.identifier! {
        case "ShowProgramDetails":
            let dest = segue.destinationViewController as! LiveProgramDetailsViewController
            dest.program = (sender as! TVGridTableViewCell).selectedProgramm
            let popOverPresentationController = segue.destinationViewController.popoverPresentationController
            popOverPresentationController!.sourceRect  = (sender as! TVGridTableViewCell).sequeAnchor.frame
            popOverPresentationController!.sourceView  = (sender as! TVGridTableViewCell)
        default: break
            
        }
    }
    // MARK: - Time Grid
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return timeCells
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TimeGridItem", forIndexPath: indexPath) as! LiveTVTimeGridViewCell
        let cellTime  = tvGrid.tvGridStartTime.dateByAddingTimeInterval(Double(indexPath.row*30*60) )
        cell.title?.text = cellTime.toShortTimeString()        
        return cell
    }
    
    
    func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath?{
        return NSIndexPath(forItem: 0, inSection: 0)
    }
    
    // MARK: UICollectionViewFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        let width = CGFloat(7*30) - 2//((self.timeGrid?.frame.width)! - 7) / 8
        return CGSizeMake(width, 50)
    }


    //MARK: - TVGridDataSourceDelegate
    func tvGridDataSource(tvGridDataSource: TVGridDataSource, didChangeObjects: NSRange){
        let indexPaths =  NSIndexSet(indexesInRange: NSRange(location:didChangeObjects.location,length:didChangeObjects.length))
        guard let visible = self.tableView.indexPathsForVisibleRows else {
            self.tableView.insertSections(indexPaths, withRowAnimation: .Automatic)
            return
        }
        
        guard visible.count > 0 else {
            self.tableView.insertSections(indexPaths, withRowAnimation: .Automatic)
            return
        }
        
        if self.tableView.numberOfSections < (didChangeObjects.location + didChangeObjects.length){
            self.tableView.insertSections(indexPaths, withRowAnimation: .Automatic)
        }
        else{
            self.tableView.reloadSections(indexPaths, withRowAnimation: .Automatic)
        }
    }
    func controllerWillChangeContent(tvGridDataSource: TVGridDataSource ){
        self.tableView.beginUpdates()
    }
    func controllerDidChangeContent(tvGridDataSource: TVGridDataSource ){
        self.tableView.endUpdates()
    }
    func tvGridDataSource(tvGridDataSource: TVGridDataSource, didGetError: ErrorType){
        
    }
}
