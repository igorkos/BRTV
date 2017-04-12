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
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(LiveTVCollectionViewController.updateData), name:NSNotification.Name(rawValue: NotificationUpdateLayoutData), object: nil)
        collectionView!.remembersLastFocusedIndexPath = true
        
        tvGrid.delegate = self
        tvGrid.reloadGrid()        
    }
    
    override func viewWillAppear(_ animated: Bool){
         tvGrid.updateGrid()
    }
    
    func updateData(){
        tvGrid.updateGrid()
    }
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch  segue.identifier! {
        case "ShowProgramDetails":
            let dest = segue.destination as! LiveProgramDetailsViewController
            let cell = sender as! LiveTVGridViewCell
            dest.program = cell.programData
            dest.contentType = .live
            let popOverPresentationController = segue.destination.popoverPresentationController
            let index = IndexPath(item: 0, section: cell.indexPath!.section)
            let view = collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: index)
            popOverPresentationController!.sourceRect  = view!.frame
            popOverPresentationController!.sourceView  = collectionView
        default: break
            
        }
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tvGrid.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return  1000
        }
        let channel = tvGrid[section]
        return channel!.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseTimeIdentifier, for: indexPath) as! LiveTVTimeGridViewCell
            let cellTime  = tvGrid.tvGridStartTime + (indexPath.item*30*60)
            cell.title?.text = cellTime.toShortString()
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LiveTVGridViewCell
            let channel = tvGrid[indexPath.section]
            cell.programData = channel![indexPath.item]
            cell.indexPath = indexPath
            return cell
        }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView{
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseChannelIdentifier, for: indexPath) as! LiveTVGridChannelIconView
        let channel = tvGrid[indexPath.section]
        Functions.loadImage(channel!.id, mediaType: BRTVAPIImageType.chanelLogoOriginal, index: 1, imageView: cell.icon!)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool{
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator){
        if context.previouslyFocusedIndexPath != nil {
            let cell = collectionView.cellForItem(at: context.previouslyFocusedIndexPath!)
            switch cell {
            case is LiveTVGridViewCell:
                cell!.backgroundColor = UIColor.white
            case is LiveTVTimeGridViewCell:
                cell!.backgroundColor = UIColor.darkGray
            default:
                break
            }

        }
        if context.nextFocusedIndexPath != nil {
            let  cell = collectionView.cellForItem(at: context.nextFocusedIndexPath!)
            switch cell {
            case is LiveTVGridViewCell:
                cell!.backgroundColor = UIColor.gray
            case is LiveTVTimeGridViewCell:
                cell!.backgroundColor = UIColor.gray
            default:
                break
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        let cell = collectionView.cellForItem(at: indexPath)
        if cell is  LiveTVGridViewCell {
            performSegue(withIdentifier: "ShowProgramDetails", sender: cell)
        }
    }

    
    // MARK: - UICollectionViewFlowLayout
    
    func randomNumber(_ range: Range<Int> = 1..<7) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
        return CGSize(width: width, height: 120)
   }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize( width: 120, height: 120)
    }
    
    //MARK: - TVGridDataSourceDelegate
    var spinner : SwiftSpinner?
    func tvGridDataSource(_ tvGridDataSource: TVGridDataSource, didChangeObjects: NSRange){
    }
    func controllerWillChangeContent(_ tvGridDataSource: TVGridDataSource ){
        spinner = SwiftSpinner.show("Loading TV Programs...",toView: self.view)
    }
    func controllerDidChangeContent(_ tvGridDataSource: TVGridDataSource ){
        (collectionView?.collectionViewLayout as! InfiniteHorizontalLayout).maxWith = 0
        collectionView?.reloadData()
        spinner?.hide()
    }
    func tvGridDataSource(_ tvGridDataSource: TVGridDataSource, didGetError: Error){
        
    }

    
}
