//
//  ChanelProgramsData.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/18/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}






let GRID_TIME_AHEAD_SEC : Duration = Duration(8 * 3600)
let GRID_TIME_BACK_SEC : Duration = Duration(3 * 3600)

class TVGridDataSource {
    static let sharedInstance = TVGridDataSource()
    weak var delegate : TVGridDataSourceDelegate?
    
    fileprivate var tvGrid : TVGrid?
    var tvGridStartTime: DateTime = DateTime(lastPeriodMark:30)
    var tvGridEndTime: DateTime = DateTime(lastPeriodMark:30) + GRID_TIME_AHEAD_SEC
    
    var tvGridRequestStartTime: DateTime = DateTime()
    fileprivate var loading = false
    
    func isNeedReload(){
        let nowTime = DateTime(lastPeriodMark:30)
        if nowTime != tvGridStartTime{
            
        }
    }
    //Load TVGrid from 1 hour back from now to 8 hour ahead
    func reloadGrid(){
        Log.d("")
        if self.delegate != nil {
            DispatchQueue.main.async(execute: {
                self.delegate!.controllerWillChangeContent(self)
            })
        }
        tvGridStartTime = DateTime(lastPeriodMark:30)
        tvGridEndTime  = tvGridStartTime + GRID_TIME_AHEAD_SEC
        tvGridRequestStartTime = tvGridStartTime
        loadTVGrid(tvGridRequestStartTime,end: tvGridEndTime, page: 1)
    }
    
    func updateGrid(){
        if loading {
            return
        }
        
        var from = DateTime(lastPeriodMark:30);
        if from != tvGridRequestStartTime {
            tvGrid!.remove(from)
            tvGridRequestStartTime = from
            from = tvGridEndTime
            if self.delegate != nil {
                DispatchQueue.main.async(execute: {
                    self.delegate!.controllerWillChangeContent(self)
                })
            }
            tvGridRequestStartTime = from
            tvGridEndTime = tvGridRequestStartTime + GRID_TIME_AHEAD_SEC
            loadTVGrid(tvGridRequestStartTime, end:tvGridEndTime, page: 1)
        }
    }
    
    fileprivate func loadTVGrid(_ start:DateTime, end:DateTime, page: Int){
        loading = true
        BRTVAPI.sharedInstance.getClientTVGrid(start, end: end, page: page, completion: { (response: AnyObject?, error: Error?) in
                guard let new_grid = response as? TVGrid else {
                    //Error
                    if self.delegate != nil{
                        DispatchQueue.main.async(execute: {
                            self.delegate!.tvGridDataSource(self, didGetError: error!)
                        })
                    }
                    return
                }
                
                Log.d("Recived page:\(new_grid.paging!.pageNumber) with \(new_grid.count) channels")
                
                let range = NSRange(location: ((new_grid.paging?.pageNumber)!-1)*(new_grid.paging?.itemsOnPage)! , length: new_grid.count)
                //First time load
                guard self.tvGrid != nil else {
                    self.tvGrid = new_grid
                    if self.delegate != nil{
                        DispatchQueue.main.async(execute: {
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
                    DispatchQueue.main.async(execute: {
                        self.delegate!.tvGridDataSource(self, didChangeObjects:range)
                    })
                }
                
                if self.tvGrid!.paging?.pageNumber <= self.tvGrid!.paging?.totalPages {
                    //Not all pages loaded load next
                    self.loadTVGrid( start,end: end, page: (self.tvGrid!.paging?.pageNumber)! + 1)
                }
                else{
                    //All loaded
                    self.loading = false
                    if self.delegate != nil{
                        DispatchQueue.main.async(execute: {
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

