//
//  ArchiveChannel.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/6/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation

class ArchiveChannel : JSONDecodable{
    
    weak var delegate : ArchiveChannelDelegate?
    
    //MARK: JSON parsing
    var accessNum : Int //Channel access number displayed in the box beside the channel. Dial the number on a remote to switch to the channel
    var advisory  : Int //Content advisory raiting of the channel
    var arX  : Int //X-axis aspect
    var arY : Int //Y-axis aspect
    var id  : Int // Item id of a TV channel
    var name : String? //TV channel display name
    var orderNum  : Int //Current channel position for displaying the channel in the channel list
    var programs : Array<TVGridProgram>? //List of TV programs
    var UtcOffset : Int
    var programsSectioned : Array<Array<TVGridProgram>> = []
    required init( accessNum : Int, advisory  : Int, arX  : Int, arY : Int, id  : Int, name : String?, orderNum  : Int,UtcOffset : Int){
        self.accessNum = accessNum
        self.advisory = advisory
        self.arX = arX
        self.arY = arY
        self.id = id
        self.name = name
        self.orderNum = orderNum
        self.UtcOffset = UtcOffset
    }
    
    static func create(accessNum : Int)( advisory  : Int)(arX  : Int)( arY : Int)( id  : Int)( name : String?)( orderNum  : Int)(UtcOffset : Int) -> ArchiveChannel {
        return ArchiveChannel(accessNum : accessNum, advisory  : advisory, arX  : arX, arY : arY, id  : id, name : name, orderNum  : orderNum,UtcOffset: UtcOffset)
    }
    static func arrayKey() ->String{
        return "items"
    }
    static func decode(json: JSON) -> ArchiveChannel? {
        return  _JSONObject(json) >>> { d in
            ArchiveChannel.create <^>
                _JSONInt(d["accessNum"]) <*>
                _JSONInt(d["advisory"]) <*>
                _JSONInt(d["arX"]) <*>
                _JSONInt(d["arY"]) <*>
                _JSONInt(d["id"]) <*>
                _JSONString(d["name"]) <*>
                _JSONInt(d["orderNum"]) <*>
                _JSONInt(d["UtcOffset"])
        }
    }
    private func loadPage(page:Int){
        BRTVAPI.sharedInstance.getArchiveProgramGuide(self.id,page: page, completion: { (response: AnyObject?, error: ErrorType?) in
            guard let res = response else{
                Log.d("\(error)")
                return
            }
            let channelProg = res as! AchiveChannelPrograms
            self.programs?.appendContentsOf(channelProg.programs!)
            if channelProg.paging?.pageNumber < (channelProg.paging!.totalPages - 1){
                self.loadPage(channelProg.paging!.pageNumber + 1)
                return
            }
            self.programs!.sortInPlace({
                $0.startTime > $1.startTime
            })
            
            var section = Array<TVGridProgram>()
            var last : TVGridProgram?
            for pr in self.programs! {
                if last == nil{
                   section.append(pr)
                }
                else{
                    if last?.startTime.day != pr.startTime.day{
                        section.sortInPlace({
                            $0.startTime < $1.startTime
                        })
                        self.programsSectioned.append(section)
                        section = Array<TVGridProgram>()
                    }
                    section.append(pr)
                }
                last = pr
            }
            self.programsSectioned.append(section)
            if self.delegate != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate!.controllerDidChangeContent(self)
                })
            }
        })
    }
    
    func requestPrograms(){
        if programs == nil {
            if self.delegate != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate!.controllerWillChangeContent(self)
                })
            }
            programs = []
            BRTVAPI.sharedInstance.getArchiveTimeSpan(id,completion: { (response: AnyObject?, error: ErrorType?) in
                let span : BRTVResponseObject? = response as? BRTVResponseObject
                Log.d("\(span?.response)")
            })
            loadPage(0)
        }
        else{
            if self.delegate != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate!.controllerDidChangeContent(self)
                })
            }
        }
    }
    
    subscript(index: Int) -> Array<TVGridProgram>?{
        get
        {
            guard programsSectioned.count > index else {
                assertionFailure("TVGridChannel -> program index out of range index=\(index) items:\(programsSectioned.count)")
                return nil
            }
            return programsSectioned[index]
        }
    }
    
    var count : Int {
        get{
            return programsSectioned.count
        }
    }

}

protocol ArchiveChannelDelegate : NSObjectProtocol{
    func controllerWillChangeContent(tvGridDataSource: ArchiveChannel )
    func controllerDidChangeContent(tvGridDataSource: ArchiveChannel )
    func tvGridDataSource(tvGridDataSource: ArchiveChannel, didGetError: ErrorType)
}