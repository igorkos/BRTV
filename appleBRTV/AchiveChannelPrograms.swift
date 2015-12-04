//
//  AchiveChannelPrograms.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/7/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation

class AchiveChannelPrograms : JSONDecodable{
    var paging : ItemPaging?
    var programs : Array<TVGridProgram>? //List of TV programs
    
    required init( programs : Array<TVGridProgram>?, paging : ItemPaging?){
        self.paging = paging
        self.programs = programs
    }
    
    static func create( paging : ItemPaging?)(programs : Array<TVGridProgram>?) -> AchiveChannelPrograms {
        return AchiveChannelPrograms(programs : programs, paging : paging)
    }
    
    static func arrayKey() ->String{
        return ""
    }
    static func decode(json: JSON) -> AchiveChannelPrograms? {
        return _JSONObject(json) >>> { d in
            AchiveChannelPrograms.create <^>
                ItemPaging.decode(_JSONObject(d["paging"])) <*>
                _JSONArray(d["items"]) >>> { c in
                    var array = Array<TVGridProgram>()
                    for channelData in c {
                        let channel = TVGridProgram.decode(channelData)
                        array.append(channel!)
                    }
                    return array
            }
        }
    }
}