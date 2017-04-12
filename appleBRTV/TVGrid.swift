//
//  TVGridObject.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/22/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

//MARK: operators
func += (left: TVGrid, right: TVGrid) -> TVGrid {
    var startIndex = (right.page - 1)*(right.paging?.itemsOnPage)!
    let endIndex = startIndex + right.count
    if (left.chanels?.count)! < endIndex {
       left.chanels?.append(contentsOf: right.chanels!)
       left.paging?.pageNumber = right.page
    }
    else{
        for channel in right.chanels! {
            left[startIndex]! += channel
            startIndex += 1
        }
        left.paging?.pageNumber = right.page
    }
    return left
}

class TVGrid {
    
    //MARK: JSON parsing
    var chanels : [TVGridChannel]?
    var paging :  ItemPaging?
    
    required init(paging :  ItemPaging?,chanels : [TVGridChannel]?){
        self.chanels = chanels
        self.paging = paging
    }
    
    static func create(_ paging :  ItemPaging?, _ chanels : [TVGridChannel]?) -> TVGrid {
        return TVGrid(paging:paging,chanels:chanels)
    }
    
    static func decode(_ json: JSON) -> Decoded<TVGrid>? {
        return curry( TVGrid.init )
            <^> json <| "paging"
            <*> json <|| "chanels"
    }

    static func arrayKey() ->String{
        return ""
    }
    //MARK: properties
    var count : Int {
        get{
            guard let ch = chanels else{
                return 0
            }
            return ch.count
        }
    }
    
    var page : Int {
        get{
            guard let page = paging else {
                return 0
            }
            return page!.pageNumber
        }
    }
    
    var totalPages : Int {
        get{
            guard let page = paging else {
                return 0
            }
            return page!.totalPages
        }
    }
    
    //MARK: Subscripts
    subscript(index: Int) -> TVGridChannel?
        {
        get
        {
            guard var ch = chanels else{
                assert(false, "Not inicialized")
                return nil
            }
            guard ch.count > index  else {
                assert(false, "Index out of range")
                return nil
            }
            return ch[index]
        }
    }
    
    func remove( _ time: DateTime){
        for chanel in chanels! {
            chanel.remove(time)
        }
    }
    
}
