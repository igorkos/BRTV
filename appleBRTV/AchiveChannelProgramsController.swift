//
//  AchiveChannelsRootController.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/6/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

class ProgramTableViewCell: UITableViewCell {
    
    weak var programData: TVGridProgram? = nil
    
    override func layoutSubviews(){
        super.layoutSubviews()
        if programData != nil {
            self.textLabel?.text = programData!.name
            self.detailTextLabel?.text = programData!.formatedShowTime()
        }
    }
}

class AchiveChannelProgramsController: UITableViewController, ArchiveChannelDelegate {
    var spinner : SwiftSpinner?
    
    var channel : ArchiveChannel? {
        didSet{
            channel?.delegate = self
            channel?.requestPrograms()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch  segue.identifier! {
        case "ShowProgramDetails":
            let dest = segue.destinationViewController as! LiveProgramDetailsViewController
            let cell = sender as! ProgramTableViewCell
            dest.program = cell.programData
            dest.contentType = .Archive
            let split = self.splitViewController as! ArchiveSplitViewController
            let master = split.master!
            let chCell = master.cellFroProgramId(cell.programData!.channelID)
            let popOverPresentationController = segue.destinationViewController.popoverPresentationController
            popOverPresentationController!.sourceRect  = (chCell?.frame)!
            popOverPresentationController!.sourceView  = master.tableView
        default: break
            
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        guard let ch = channel else{
            return 0
        }
        return ch.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let ch = channel else{
            return 0
        }
        guard let sec = ch[section] else{
            return 0
        }
        return sec.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProgramCell", forIndexPath: indexPath) as! ProgramTableViewCell
        let program = channel![indexPath.section]![indexPath.row]
        cell.programData = program
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        let program = channel![section]![0]
        return program.startTime.toShortDateString()
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        performSegueWithIdentifier("ShowProgramDetails", sender: cell)
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
    
    func controllerWillChangeContent(tvGridDataSource: ArchiveChannel ){
        spinner?.hide()
        spinner = SwiftSpinner.show("Loading Achived Programs...",toView: self.tableView)
    }
    func controllerDidChangeContent(tvGridDataSource: ArchiveChannel ){
        tableView.reloadData()
        spinner?.hide()
    }
    func tvGridDataSource(tvGridDataSource: ArchiveChannel, didGetError: ErrorType){
        
    }

}
