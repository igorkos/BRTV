//
//  AchiveChannelsRootController.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/6/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit
class ChannelTableViewCell: UITableViewCell {
    @IBOutlet var title : UILabel? = nil
    @IBOutlet var icon : UIImageView? = nil
    
    weak var channelData: ArchiveChannel? = nil

    override func layoutSubviews(){
        super.layoutSubviews()
        if channelData != nil {
            title?.text = channelData!.name
            icon?.image = nil
            Functions.loadImage(channelData!.id, mediaType: BRTVAPIImageType.chanelLogoOriginal, index: 1, imageView: icon!)
        }
    }
}

class AchiveChannelsRootController: UITableViewController, TVArchiveDataSourceDelegate {
    let archiveDataSource = TVArchiveDataSource.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        archiveDataSource.delegate = self
        archiveDataSource.requestChannels()
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cellFroProgramId(_ channelID: Int) -> ChannelTableViewCell? {
        let index = tableView.indexPathForSelectedRow
        let cell = tableView.cellForRow(at: index!)  as! ChannelTableViewCell
        return cell
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return archiveDataSource.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelTableViewCell
        let channel = archiveDataSource[indexPath.row]
        cell.channelData = channel
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let split = self.splitViewController as? ArchiveSplitViewController
        let detail = split?.detail
        detail?.channel = archiveDataSource[indexPath.row]
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */

    func tvGridDataSource(_ tvGridDataSource: TVArchiveDataSource, didChangeObjects: NSRange){
        
    }
    func controllerWillChangeContent(_ tvGridDataSource: TVArchiveDataSource ){
        
    }
    func controllerDidChangeContent(_ tvGridDataSource: TVArchiveDataSource ){
        tableView.reloadData()
    }
    func tvGridDataSource(_ tvGridDataSource: TVArchiveDataSource, didGetError: Error){
        
    }
}