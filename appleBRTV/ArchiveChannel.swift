//
//  ArchiveChannel.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/6/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

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


class ArchiveChannel {
    
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
    
    static func create(_ accessNum : Int,  _ advisory  : Int, _ arX  : Int,  _ arY : Int,  _ id  : Int,  _ name : String?,  _ orderNum  : Int, _ UtcOffset : Int) -> ArchiveChannel {
        return ArchiveChannel(accessNum : accessNum, advisory  : advisory, arX  : arX, arY : arY, id  : id, name : name, orderNum  : orderNum,UtcOffset: UtcOffset)
    }
    static func arrayKey() ->String{
        return "items"
    }
    static func decode(_ json: JSON) -> Decoded<ArchiveChannel>? {
        return curry(ArchiveChannel.init)
            <^> json <| "accessNum"
            <*> json <| "advisory"
            <*> json <| "arX" // Use ? for parsing optional values
            <*> json <| "arY" // Custom types that also conform to Decodable just work
            <*> json <| "id" // Parse nested objects
            <*> json <| "name" // parse arrays of objects
            <*> json <| "orderNum" // parse arrays of objects
            <*> json <| "UtcOffset" // parse arrays of objects
    }
    
    fileprivate func loadPage(_ page:Int){
        BRTVAPI.sharedInstance.getArchiveProgramGuide(self.id,page: page, completion: { (response: AnyObject?, error: Error?) in
            guard let res = response else{
                Log.d("\(error)")
                return
            }
            let channelProg = res as! AchiveChannelPrograms
            self.programs?.append(contentsOf: channelProg.programs!)
            if channelProg.paging?.pageNumber < (channelProg.paging!.totalPages - 1){
                self.loadPage(channelProg.paging!.pageNumber + 1)
                return
            }
            self.programs!.sort(by: {
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
                        section.sort(by: {
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
                DispatchQueue.main.async(execute: {
                    self.delegate!.controllerDidChangeContent(self)
                })
            }
        })
    }
    
    func requestPrograms(){
        if programs == nil {
            if self.delegate != nil {
                DispatchQueue.main.async(execute: {
                    self.delegate!.controllerWillChangeContent(self)
                })
            }
            programs = []
            BRTVAPI.sharedInstance.getArchiveTimeSpan(id,completion: { (response: AnyObject?, error: Error?) in
                let span : BRTVResponseObject? = response as? BRTVResponseObject
                Log.d("\(String(describing: span?.response))")
            })
            loadPage(0)
        }
        else{
            if self.delegate != nil {
                DispatchQueue.main.async(execute: {
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
    func controllerWillChangeContent(_ tvGridDataSource: ArchiveChannel )
    func controllerDidChangeContent(_ tvGridDataSource: ArchiveChannel )
    func tvGridDataSource(_ tvGridDataSource: ArchiveChannel, didGetError: Error)
}
