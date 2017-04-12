//
//  ChanelProgramsData.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/18/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

class TVArchiveDataSource {
    static let sharedInstance = TVArchiveDataSource()
    weak var delegate : TVArchiveDataSourceDelegate?
    
    fileprivate var loading = false
    fileprivate var archiveChannels : Array<ArchiveChannel>?
    //Load TVGrid from 1 hour back from now to 8 hour ahead
    func requestChannels(){
        Log.d("")
        if self.delegate != nil {
            DispatchQueue.main.async(execute: {
                self.delegate!.controllerWillChangeContent(self)
            })
        }
        loadArchiveChannels()
    }
    
    fileprivate func loadArchiveChannels(){
        loading = true
        BRTVAPI.sharedInstance.getClientArchiveChannels({ (response: AnyObject?, error: Error?) in
            self.archiveChannels = (response as? BRTVResponseArrayObject<ArchiveChannel>)?.array            
            if self.delegate != nil{
                DispatchQueue.main.async(execute: {
                    self.delegate!.controllerDidChangeContent(self)
                })
            }
        })
    }
    
    var count : Int {
        get{
            guard let channels = archiveChannels else{
                return 0
            }
            return channels.count
        }
    }
    
    subscript(index: Int) -> ArchiveChannel?{
        get
        {
            guard let channels = archiveChannels else{
                return nil
            }
            return channels[index]
        }
    }
}

protocol TVArchiveDataSourceDelegate : NSObjectProtocol{
    func tvGridDataSource(_ tvGridDataSource: TVArchiveDataSource, didChangeObjects: NSRange)
    func controllerWillChangeContent(_ tvGridDataSource: TVArchiveDataSource )
    func controllerDidChangeContent(_ tvGridDataSource: TVArchiveDataSource )
    func tvGridDataSource(_ tvGridDataSource: TVArchiveDataSource, didGetError: Error)
}
