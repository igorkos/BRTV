//
//  AchiveChannelPrograms.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/7/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

class AchiveChannelPrograms {
    var paging : ItemPaging?
    var programs : [TVGridProgram]? //List of TV programs
    
    required init( programs : [TVGridProgram], paging : ItemPaging?){
        self.paging = paging
        self.programs = programs
    }
    
    static func create( _ paging : ItemPaging?, _ programs : [TVGridProgram]?) -> AchiveChannelPrograms {
        return AchiveChannelPrograms(programs : programs!, paging : paging)
    }
    
    static func arrayKey() ->String{
        return ""
    }
    static func decode(_ json: JSON) -> Decoded<AchiveChannelPrograms>? {
        return curry(AchiveChannelPrograms.init)
            <^> json <|| "programs"
            <*> json <| "paging"
    }
}
