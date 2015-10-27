//
//  ChanelProgramsData.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/18/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit





let GRID_TIME_AHEAD_SEC : Double = 8 * 3600
let GRID_TIME_BACK_SEC : Double = -3 * 3600

class TVGridDataSource {
    
    weak var delegate : TVGridDataSourceDelegate?
    
    private var tvGrid : TVGrid?
    var tvGridStartTime: NSDate = NSDate().closestTo(30)
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
        tvGridStartTime = NSDate().closestTo(30)
        tvGridEndTime  = NSDate(timeIntervalSinceNow:GRID_TIME_AHEAD_SEC)
        tvGridRequestStartTime = tvGridStartTime
        loadTVGrid(tvGridRequestStartTime!,end: tvGridEndTime, page: 1)
    }
    
    func updateGrid(fromTime: NSDate ){
        print("TVGridDataSource -> updateGrid current:\(tvGridRequestStartTime?.toTimeString()) <-> \(tvGridEndTime.toTimeString()) request from:\(fromTime.toTimeString())")
        if loading {
            return
        }
        let from = NSDate(timeInterval: GRID_TIME_BACK_SEC, sinceDate: fromTime)
        
            if self.delegate != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate!.controllerWillChangeContent(self)
                })
            }
            tvGridRequestStartTime = from
            tvGridEndTime = NSDate(timeInterval:GRID_TIME_AHEAD_SEC, sinceDate: tvGridRequestStartTime!)
            loadTVGrid(tvGridRequestStartTime!, end:tvGridEndTime, page: 1)
    }
    
    private func loadTVGrid(start:NSDate, end:NSDate, page: Int){
        print("TVGridDataSource -> loadTVGrid page:\(page)")
        loading = true
        BRTVAPI.sharedInstance.getClientTVGrid(start, end: end, page: page, completion: { (response: AnyObject?, error: ErrorType?) in
                guard let new_grid = response as? TVGrid else {
                    //Error
                    if self.delegate != nil{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.delegate!.tvGridDataSource(self, didGetError: error!)
                        })
                    }
                    return
                }
                
                print("TVGridDataSource -> loadTVGrid recived page:\(new_grid.paging?.pageNumber) with \(new_grid.count) channels")
                
                let range = NSRange(location: ((new_grid.paging?.pageNumber)!-1)*(new_grid.paging?.itemsOnPage)! , length: new_grid.count)
                //First time load
                guard self.tvGrid != nil else {
                    self.tvGrid = new_grid
                    if self.delegate != nil{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.delegate!.tvGridDataSource(self, didChangeObjects:range)
                        })
                    }
                    //Load next page
                    self.loadTVGrid( start,end: end, page: (self.tvGrid!.paging?.pageNumber)! + 1)
                    return
                }
                
                //Update grid
                self.tvGrid! += new_grid
                
                if self.delegate != nil{
                    //Notify changed channels
                    dispatch_async(dispatch_get_main_queue(), {
                        self.delegate!.tvGridDataSource(self, didChangeObjects:range)
                    })
                }
                
                if self.tvGrid!.paging?.pageNumber != self.tvGrid!.paging?.totalPages {
                    //Not all pages loaded load next
                    self.loadTVGrid( start,end: end, page: (self.tvGrid!.paging?.pageNumber)! + 1)
                }
                else{
                    //All loaded
                    self.loading = false
                    if self.delegate != nil{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.delegate!.controllerDidChangeContent(self)
                        })
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
