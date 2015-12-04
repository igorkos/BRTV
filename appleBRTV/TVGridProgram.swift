//
//  TVGridProgram.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/23/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation

class TVGridProgram : JSONDecodable{
    
    var advisory : Int// Program advisory
    var bookmarked : Bool //true when user marked it as favorite. always false when recorded == false
    var description : String? //TV program's long description
    var id : Int //Item id of a TV program
    var imageCount : Int //Number of available images
    var length : Int //Length of the TV program in seconds
    var name : String //TV program display name
    var recorded : Bool //Flag indicating that the program is recorded and available in archives (DVR and ArcPlus).
    var startOffset : Int //saved last watched position for DVR items
    var startTime : DateTime //TV prgram start time

    var endTime : DateTime //TV prgram end time
    var UtcOffset : Int
    var channelID : Int
    
    
    //MARK: JSON parsing
    required init( advisory : Int,bookmarked : Bool,description : String?,id : Int,imageCount : Int,length : Int,name : String,recorded : Bool,startOffset : Int,startTime : String,itemTime : String, UtcOffset : Int,channelID : Int){
        self.advisory = advisory
        self.bookmarked = bookmarked
        self.description = description
        self.id = id
        self.imageCount = imageCount
        self.length = length
        self.name = name
        self.recorded = recorded
        self.startOffset = startOffset
        self.UtcOffset = UtcOffset
        if startTime.characters.count == 0 {
            self.startTime = DateTime(input: itemTime,zone: Zone.utc())!
        }
        else{
            self.startTime = DateTime(input: startTime)!
        }
        self.startTime -= self.UtcOffset*60
        self.endTime = self.startTime + self.length*60
        self.channelID = channelID
    }
    
    required init( advisory : Int,bookmarked : Bool,description : String?,id : Int,imageCount : Int,length : Int,name : String,recorded : Bool,startOffset : Int,startTime : DateTime,itemTime : String,UtcOffset : Int,channelID : Int){
        self.advisory = advisory
        self.bookmarked = bookmarked
        self.description = description
        self.id = id
        self.imageCount = imageCount
        self.length = length
        self.name = name
        self.recorded = recorded
        self.startOffset = startOffset
        self.UtcOffset = UtcOffset
        self.startTime = startTime
        self.endTime = self.startTime + self.length
        self.channelID = channelID

    }
    
    static func create(advisory : Int)(bookmarked : Bool)(description : String?)(id : Int)(imageCount : Int)(length : Int)(name : String)(recorded : Bool)(startOffset : Int)(startTime : String)(itemTime : String)(UtcOffset : Int)(channelID : Int) -> TVGridProgram {
        return TVGridProgram(advisory : advisory,bookmarked : bookmarked,description : description,id : id,imageCount : imageCount,length : length,name : name,recorded : recorded,startOffset : startOffset,startTime : startTime,itemTime:itemTime,UtcOffset : UtcOffset,channelID : channelID)
    }
    
    static func decode(json: JSON) -> TVGridProgram? {
        return _JSONObject(json) >>> { d in
            TVGridProgram.create <^>
                _JSONInt(d["advisory"]) <*>
                _JSONBool(d["bookmarked"]) <*>
                _JSONString(d["description"]) <*>
                _JSONInt(d["id"]) <*>
                _JSONInt(d["imageCount"]) <*>
                _JSONInt(d["length"]) <*>
                _JSONString(d["name"]) <*>
                _JSONBool(d["recorded"]) <*>
                _JSONInt(d["startOffset"]) <*>
                _JSONString(d["startTime"]) <*>
                _JSONString(d["item_date"]) <*>
                _JSONInt(d["UtcOffset"]) <*>
                _JSONInt(d["channelID"])
        }
    }
    
    static func arrayKey() ->String{
        return "items"
    }
    
    func formatedShowTime() -> String {
        let time = "\(startTime.toShortString()) : \(endTime.toShortString())"
        return time
    }
    
  

    
}
