//
//  BRTVResponseObject.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/22/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

class BRTVResponseObject{
    
    var response : AnyObject?
    //MARK: JSON parsing    
    required init( response:AnyObject?){
        self.response = response
    }
    
    static func create(_ response:AnyObject?) -> BRTVResponseObject {
        return BRTVResponseObject(response:response)
    }
    
    static func decode(_ json: JSON) -> Decoded<BRTVResponseObject>? {
        return curry(BRTVResponseObject.init)
            <^> json <| "response"
    }
    
    static func arrayKey() ->String{
        return ""
    }
}

class BRTVResponseArrayObject<A> {
    
    var response : Dictionary<String,AnyObject>?
    var array : [A]

    //MARK: JSON parsing
    required init( response:AnyObject?){
        self.response = response as? Dictionary<String,AnyObject>
    }
    
    static func create(_ response:AnyObject?) -> BRTVResponseArrayObject<A> {
        return BRTVResponseArrayObject<A>(response:response)
    }
    
    static func decode(_ json: JSON) -> Decoded<BRTVResponseArrayObject<A>>? {
        return curry(BRTVResponseArrayObject.init)
            <^> json <| "response"
    /*
        return _JSONAnyObject(json) >>> { d in
            let object = BRTVResponseArrayObject<A>.create(d)
            let respArray = object.response![A.arrayKey()] as! Array<AnyObject>
            for itemData in respArray {
                let item : A = (A.decode(itemData) as? A)!
                object.array.append(item)
            }
            return object

        }
  */
    }
    static func arrayKey() ->String{
        return ""
    }
}
