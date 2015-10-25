//
//  ChanelProgramsData.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/18/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit





let GRID_TIME_AHEAD_SEC : Double = 8 * 3600
let GRID_TIME_BACK_SEC : Double = -1 * 3600

class TVGridDataSource {
    
    weak var delegate : TVGridDataSourceDelegate?
    
    private var tvGrid : TVGrid?
    var tvGridStartTime: NSDate = NSDate(timeIntervalSinceNow:GRID_TIME_BACK_SEC).closestTo(30)
    var tvGridEndTime: NSDate = NSDate(timeIntervalSinceNow:GRID_TIME_AHEAD_SEC)
    private var tvGridRequestStartTime: NSDate? = nil
    private var loading = false
    //Load TVGrid from 1 hour back from now to 8 hour ahead
    func reloadGrid(){
        print("TVGridDataSource -> reloadGrid")
        if self.delegate != nil {
            dispatch_async(dispatch_get_main_queue(), {
                self.delegate!.controllerWillChangeContent(self)
            })
        }
        tvGridStartTime = NSDate(timeIntervalSinceNow:GRID_TIME_BACK_SEC).closestTo(30)
        tvGridEndTime  = NSDate(timeIntervalSinceNow:GRID_TIME_AHEAD_SEC)
        tvGridRequestStartTime = tvGridStartTime
        loadTVGrid(tvGridRequestStartTime!,end: tvGridEndTime, page: 1)
    }
    
    func updateGrid(fromTime: NSDate ){
        print("TVGridDataSource -> updateGrid current:\(tvGridRequestStartTime) <-> \(tvGridEndTime) request from:\(fromTime)")
        if tvGridEndTime.compare(fromTime) == .OrderedAscending{
            if loading {
                return
            }
            if self.delegate != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate!.controllerWillChangeContent(self)
                })
            }
            tvGridRequestStartTime = tvGridEndTime
            tvGridEndTime = NSDate(timeInterval:GRID_TIME_AHEAD_SEC, sinceDate: tvGridRequestStartTime!)
            loadTVGrid(tvGridRequestStartTime!, end:tvGridEndTime, page: 1)
        }
    }
    
    private func loadTVGrid(start:NSDate, end:NSDate, page: Int){
        print("TVGridDataSource -> loadTVGrid page:\(page)")
        loading = true
        BRTVAPI.sharedInstance.getClientTVGrid(start, end: end, page: page, completion: { (response: AnyObject?, error: ErrorType?) in
            guard let new_grid = response as? TVGrid else {
                guard let delegate = self.delegate else{
                    return
                }
                delegate.tvGridDataSource(self, didGetError: error!)
                return
            }
            
            guard self.tvGrid != nil else {
                self.tvGrid = new_grid
                self.loadTVGrid( start,end: end, page: (self.tvGrid!.paging?.pageNumber)! + 1)
                return
            }
            
            self.tvGrid! += new_grid
            if self.tvGrid!.paging?.pageNumber != self.tvGrid!.paging?.totalPages {
                self.loadTVGrid( start,end: end, page: (self.tvGrid!.paging?.pageNumber)! + 1)
                guard  self.delegate == nil else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let range = NSRange(location: (self.tvGrid!.paging?.pageNumber)!, length: (self.tvGrid!.paging?.itemsOnPage)!)
                        self.delegate!.tvGridDataSource(self, didChangeObjects:range)
                    })
                    return
                }
            }
            else{
                guard self.delegate == nil else{
                    self.loading = false
                    dispatch_async(dispatch_get_main_queue(), {
                        self.delegate!.controllerDidChangeContent(self)
                    })
                    return
                }                
            }
        })
    }
    
    
    var count : Int {
        get{
            guard let grid = tvGrid else {
                return 0
            }
            return grid.count
        }
    }
    
    subscript(index: Int) -> TVGridChannel?{
        get
        {
            guard let grid = tvGrid else {
                return nil
            }
            return grid[index]
        }
    }
}

protocol TVGridDataSourceDelegate : NSObjectProtocol{
    func tvGridDataSource(tvGridDataSource: TVGridDataSource, didChangeObjects: NSRange)
    func controllerWillChangeContent(tvGridDataSource: TVGridDataSource )
    func controllerDidChangeContent(tvGridDataSource: TVGridDataSource )
    func tvGridDataSource(tvGridDataSource: TVGridDataSource, didGetError: ErrorType)
}
