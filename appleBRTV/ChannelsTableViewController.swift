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
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
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
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return 100
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TimeGridItem", forIndexPath: indexPath) as! LiveTVTimeGridViewCell
        let cellTime  = tvGrid.tvGridStartTime.dateByAddingTimeInterval(Double(indexPath.row*30*60) )
        cell.title?.text = cellTime.toShortTimeString()
        return cell
    }
    
    
    func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath?{
        return NSIndexPath(forItem: 0, inSection: 0)
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        let width = ((self.timeGrid?.frame.width)! - 7) / 8
        return CGSizeMake(width, 50)
    }


    //MARK: - TVGridDataSourceDelegate
    func tvGridDataSource(tvGridDataSource: TVGridDataSource, didChangeObjects: NSRange){
        guard let visible = self.tableView.indexPathsForVisibleRows else {
            self.tableView.reloadData()
            return
        }
        
        guard visible.count > 0 else {
            self.tableView.reloadData()
            return
        }
        
        let visCells : NSRange = NSRange(location: visible[0].section, length: visible[visible.count - 1].section - visible[0].section)
        print("TVGridDataSourceDelegate:didChangeObjects -> visible \(visCells) changed \(didChangeObjects)")
        let intersec : NSRange = NSIntersectionRange(visCells, didChangeObjects)
        if intersec.length > 0 {
            print("TVGridDataSourceDelegate:didChangeObjects -> intersection \(intersec)")
            
        }
    }
    func controllerWillChangeContent(tvGridDataSource: TVGridDataSource ){
        
    }
    func controllerDidChangeContent(tvGridDataSource: TVGridDataSource ){
        
    }
    func tvGridDataSource(tvGridDataSource: TVGridDataSource, didGetError: ErrorType){
        
    }
}
