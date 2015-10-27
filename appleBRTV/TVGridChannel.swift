//
//  TVChannelObject.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/23/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation

func += (left: TVGridChannel, right: TVGridChannel) -> TVGridChannel {
    left.updatePrograms(right.programs)
    return left
}

protocol TVGridChannelDelegte : NSObjectProtocol{
    func tvGridChannel(tvGridChannel: TVGridChannel, didAddObjects: NSRange)
    func tvGridChannel(tvGridChannel: TVGridChannel, didRemoveObjects: NSRange)
}

class TVGridChannel : JSONDecodable{
    
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
    weak var delegate : TVGridChannelDelegte?
  
    required init( accessNum : Int, advisory  : Int, arX  : Int, arY : Int, id  : Int, name : String?, orderNum  : Int,UtcOffset : Int, programs:Array<TVGridProgram>?){
        self.accessNum = accessNum
        self.advisory = advisory
        self.arX = arX
        self.arY = arY
        self.id = id
        self.name = name
        self.orderNum = orderNum
        self.UtcOffset = UtcOffset
        self.programs = programs
    }
    
    static func create(accessNum : Int)( advisory  : Int)(arX  : Int)( arY : Int)( id  : Int)( name : String?)( orderNum  : Int)(UtcOffset : Int)(programs:Array<TVGridProgram>?) -> TVGridChannel {
        return TVGridChannel(accessNum : accessNum, advisory  : advisory, arX  : arX, arY : arY, id  : id, name : name, orderNum  : orderNum,UtcOffset: UtcOffset, programs:programs)
    }
 
    static func decode(json: JSON) -> TVGridChannel? {
        return  _JSONObject(json) >>> { d in
            TVGridChannel.create <^>
                _JSONInt(d["accessNum"]) <*>
                _JSONInt(d["advisory"]) <*>
                _JSONInt(d["arX"]) <*>
                _JSONInt(d["arY"]) <*>
                _JSONInt(d["id"]) <*>
                _JSONString(d["name"]) <*>
                _JSONInt(d["orderNum"]) <*>
                _JSONInt(d["UtcOffset"]) <*>
                _JSONArray(d["programs"]) >>> { programs in
                    let utc = _JSONInt(d["UtcOffset"])
                    let id = _JSONInt(d["id"])
                    var array = Array<TVGridProgram>()
                    let catoff = NSDate().closestTo(30)
                    for p in programs {
                        var program : JSONDictionary = p as! JSONDictionary
                        program["UtcOffset"] = utc
                        program["channelID"] = id
                        var p = TVGridProgram.decode(program)!
                        if catoff.compare(p.endTime) == .OrderedAscending {
                            array.append(p)
                        }
                    }
                    return array
                }
        }
    }
    /*

*/

    subscript(index: Int) -> TVGridProgram?
        {
        get
        {
            guard let prog = programs else {
                return nil
            }
            guard prog.count > index else {
                assertionFailure("TVGridChannel -> program index out of range index=\(index) items:\(prog.count)")
                return nil
            }            
            return prog[index]
        }
        set(program)
        {
            guard programs != nil else {
                return
            }
            guard let new_prog = program else {
                return
            }
            programs![index] = new_prog
        }
    }
    
    var count : Int {
        get{
            guard let prog = programs else {
                return 0
            }
            return prog.count
        }
    }
  
    func programLive( atTime: NSDate ) -> TVGridProgram? {
        guard let prog = programs else {
            return nil
        }
        print("programLive: \(atTime.toTimeString())")
        let result = prog.filter({
            let prog = $0
            //Calculate start time
            let start = prog.startTime
            let end = prog.endTime
            
            if atTime.compare(start) == .OrderedAscending {
                return false
            }
            if atTime.compare(end) == .OrderedDescending {
                return false
            }
            return true
        })
        guard result.count > 0 else {
            return nil
        }
        return result[0]
    }
    
    func indexOfLiveProgram() -> Int {
        guard let liveProgram = programLive( NSDate() ) else {
            return 0
        }
        let index = indexOfProgram(liveProgram)
        return index
    }
    
    func indexOfProgram( program: TVGridProgram ) -> Int {
        guard let prog = programs else {
            return -1
        }
        let index = prog.indexOf({
            $0.id == program.id
        })
        guard index != nil else {
            return -1
        }
        return index!
    }
    
    func updatePrograms(newPrograms:[TVGridProgram]?){
        guard newPrograms != nil else {
            return
        }

        let startIndex = programs?.count
        var count = 0
        for programm in newPrograms! {
            let index = indexOfProgram(programm)
            if index < 0 {
                count++
                programs!.append(programm)
            }
        }
        if delegate != nil {
            dispatch_async(dispatch_get_main_queue(), {
                self.delegate!.tvGridChannel(self, didAddObjects: NSRange(location: startIndex!, length: count))
            })
        }
    }
}
