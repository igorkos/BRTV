//
//  ChanelProgramsData.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/18/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit
class TVGridProgram {
    enum Keys : String {
        case advisory,// Program advisory
        bookmarked, //true when user marked it as favorite. always false when recorded == false
        description, //TV program's long description
        id, //Item id of a TV program
        imageCount, //Number of available images
        length, //Length of the TV program in seconds
        name, //TV program display name
        recorded, //Flag indicating that the program is recorded and available in archives (DVR and ArcPlus).
        startOffset	, //saved last watched position for DVR items
        startTime, //TV prgram start time
        UtcOffset,
        channelID
    }

    
    var program : [String:AnyObject]? = nil
  
    init( withData data: [String:AnyObject]? ){
        program = data
    }
    
    subscript(key: Keys) -> AnyObject?{
        get
        {
            return program?[key.rawValue]
        }
        set(value)
        {
            program?[key.rawValue] = value
        }
    }
    
    func startTime() -> NSDate {
        var start = NSDate(value:self[.startTime] as! String)
        //start = NSDate(timeInterval: (self[.UtcOffset] as! Double)*60, sinceDate: start)
        return start
    }
    
    func endTime() -> NSDate {
        let start = startTime()
        let end = NSDate(timeInterval: (self[.length] as! Double)*60, sinceDate: start)
        return end
    }
}

class TVGridChannel {
    
    enum Keys : String {
        case accessNum, //Channel access number displayed in the box beside the channel. Dial the number on a remote to switch to the channel
        advisory, //Content advisory raiting of the channel
        arX, //X-axis aspect
        arY, //Y-axis aspect
        id, // Item id of a TV channel
        name, //TV channel display name
        orderNum, //Current channel position for displaying the channel in the channel list
        programs, //List of TV programs
        UtcOffset
    }
    
    var channel : [String:AnyObject]? {
        didSet {
            _programs = self[.programs] as? [[String:AnyObject]]
        }
    }
    private var _programs : [[String:AnyObject]]? = nil
    
    subscript(key: Keys) -> AnyObject?{
        get
        {
            return channel?[key.rawValue]
        }
        set(value)
        {
            channel?[key.rawValue] = value
        }
    }
    
    subscript(index: Int) -> TVGridProgram?
        {
        get
        {            
            guard _programs?.count > index else {
                assert(false, "Index out of range")
                return nil
            }
            return TVGridProgram(withData: _programs![index])
        }
        set(program)
        {
            _programs![index] = (program?.program)!
            
        }
    }
    
    init(withData data:[String:AnyObject]?) {
        self.channel = data
        _programs = self[.programs] as? [[String:AnyObject]]
    }
    
    func programLive( atTime: NSDate ) -> TVGridProgram{
        let result = _programs?.filter({
            let prog = TVGridProgram(withData:$0)
            prog[.UtcOffset] = self[.UtcOffset]
            //Calculate start time
            let start = prog.startTime()
            let end = prog.endTime()
            
            if atTime.compare(start) == .OrderedAscending {
                return false
            }
            if atTime.compare(end) == .OrderedDescending {
                return false
            }
            return true
        })
        guard result?.count > 0 else {
            return TVGridProgram(withData:nil)
        }
        return TVGridProgram(withData: result?[0])
    }
    
    func indexOfLiveProgram() -> Int {
        let liveProgram = programLive( NSDate() )
        let index = indexOfProgram(liveProgram)
        print(index)
        return index
    }
    
    func indexOfProgram( program: TVGridProgram ) -> Int {
        
        let index = _programs?.indexOf({
            $0[TVGridProgram.Keys.startTime.rawValue] as! String ==  program[.startTime] as? String
        })
        guard index != nil else {
            return -1
        }
        print(index)
        return index!
    }
}

class TVGrid {
    
    enum Keys : String {
        case grid, //List of objects representing TV Channels.
        paging //Output parameter with paging information for current request for TV Guide
    }

    
    var grid : [String:AnyObject]?
    
    init(withData data:[String:AnyObject]?) {
        self.grid = data
    }
    
    subscript(key: Keys) -> AnyObject?{
        get
        {
            return grid?[key.rawValue]
        }
        set(value)
        {
            grid?[key.rawValue] = value
        }
    }
    
    subscript(index: Int) -> TVGridChannel?
        {
        get
        {
            let channels =  self[.grid] as! [[String:AnyObject]]
            guard channels.count > index  else {
                assert(false, "Index out of range")
                return nil
            }
            let channel = TVGridChannel(withData: channels[index])
            return channel
        }
    }

    var count : Int {
        get{
            let channels =  self[.grid] as! [[String:AnyObject]]
            return channels.count
        }
    }
    
}
