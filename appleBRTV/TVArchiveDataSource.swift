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
    
    private var loading = false
    private var archiveChannels : Array<ArchiveChannel>?
    //Load TVGrid from 1 hour back from now to 8 hour ahead
    func requestChannels(){
        Log.d("")
        if self.delegate != nil {
            dispatch_async(dispatch_get_main_queue(), {
                self.delegate!.controllerWillChangeContent(self)
            })
        }
        loadArchiveChannels()
    }
    
    private func loadArchiveChannels(){
        loading = true
        BRTVAPI.sharedInstance.getClientArchiveChannels({ (response: AnyObject?, error: ErrorType?) in
            self.archiveChannels = (response as? BRTVResponseArrayObject<ArchiveChannel>)?.array            
            if self.delegate != nil{
                dispatch_async(dispatch_get_main_queue(), {
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
    func tvGridDataSource(tvGridDataSource: TVArchiveDataSource, didChangeObjects: NSRange)
    func controllerWillChangeContent(tvGridDataSource: TVArchiveDataSource )
    func controllerDidChangeContent(tvGridDataSource: TVArchiveDataSource )
    func tvGridDataSource(tvGridDataSource: TVArchiveDataSource, didGetError: ErrorType)
}
