////
//  ChannelsTableViewController.swift
//  appleBRTV
//
//  Created by Aleksandr Kelbas on 12/10/2015.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit


class ChannelsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    var channelsData: TVGrid? = nil
    var tvGridStartTime: NSDate? = nil
    var tvGridCurrentTime: NSDate? = nil
    @IBOutlet var timeGrid : UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var popoverAnchor: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
//        BRTVAPI.sharedInstance.getClientChannels(NSUserDefaults.standardUserDefaults().objectForKey("sessionID"), completion: { (response: AnyObject?, error: NSError?) in
//            
//        });
        
        tvGridStartTime = NSDate().closestTo(30)
        tvGridCurrentTime = tvGridStartTime
        let end  = NSDate(timeIntervalSinceNow:3600*24)
            BRTVAPI.sharedInstance.getClientTVGrid(tvGridStartTime!, end: end, page: 1, completion: { (response: AnyObject?, error: NSError?) in
                self.channelsData = TVGrid(withData: response as? [String:AnyObject])
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            })
       
       timeLabel.text = NSDate().toShortTimeString()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func offsetTimeTable( offset: CGFloat ){
      //  tvGridCurrentTime = tvGridStartTime!.dateByAddingTimeInterval(offset*60)
      //  tvGridCurrentTime = tvGridCurrentTime?.closestTo(30)
        let point = CGPointMake(offset, 0)
        timeGrid.setContentOffset(point, animated: false)
        let cells = tableView.visibleCells as! [TVGridTableViewCell]
        for cell in cells {
           // dispatch_async(dispatch_get_main_queue()){
                cell.collectionView?.setContentOffset(point, animated: false)
            //}
        }
    }
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        guard channelsData != nil else {
            return 0
        }
        return channelsData!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
//        if channelsData.count > section{
//            let chanel : [String:AnyObject] = channelsData[section]
//            return chanel["name"] as? String
//        }
//        return nil
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChannelScrollCell", forIndexPath: indexPath) as! TVGridTableViewCell

        // Configure the cell...
        
        cell.channelData = channelsData![indexPath.section]
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
            dest.programData = (sender as! TVGridTableViewCell).selectedProgramm
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
        let cellTime  = tvGridCurrentTime!.dateByAddingTimeInterval(Double(indexPath.row*30*60) )
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


}
