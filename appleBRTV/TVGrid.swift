//
//  TVGridObject.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/22/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation

//MARK: operators
func += (left: TVGrid, right: TVGrid) -> TVGrid {
    var startIndex = (right.page - 1)*(right.paging?.itemsOnPage)!
    let endIndex = startIndex + right.count
    if (left.chanels?.count)! < endIndex {
       left.chanels?.appendContentsOf(right.chanels!)
       left.paging?.pageNumber = right.page
    }
    else{
        for channel in right.chanels! {
            left[startIndex++]! += channel
        }
        left.paging?.pageNumber = right.page
    }
    return left
}

class ItemPaging : JSONDecodable{
    var itemsOnPage : Int //Desired number of items per page
    var pageNumber  : Int//Requested page number.
    var totalItems : Int//Total number of items
    var totalPages : Int//Total number of pages
    
    
    //MARK: JSON parsing
    required init( itemsOnPage : Int, pageNumber  : Int,totalItems : Int,totalPages : Int){
        self.itemsOnPage = itemsOnPage
        self.pageNumber = pageNumber
        self.totalItems = totalItems
        self.totalPages = totalPages
    }
    
    static func create(itemsOnPage : Int)(pageNumber  : Int)(totalItems : Int)(totalPages : Int) -> ItemPaging {
        return ItemPaging(itemsOnPage: itemsOnPage, pageNumber: pageNumber,totalItems: totalItems,totalPages: totalPages)
    }
    
    static func decode(json: JSON) -> ItemPaging? {
        return _JSONObject(json) >>> { d in
            ItemPaging.create <^>
                _JSONInt(d["itemsOnPage"]) <*>
                _JSONInt(d["pageNumber"]) <*>
                _JSONInt(d["totalItems"]) <*>
                _JSONInt(d["totalPages"])
        }

    }
}


class TVGrid : JSONDecodable{
    
    //MARK: JSON parsing
    var chanels : Array<TVGridChannel>?
    var paging :  ItemPaging?
    
    required init(paging :  ItemPaging?,chanels : Array<TVGridChannel>?){
        self.chanels = chanels
        self.paging = paging
    }
    
    static func create(paging :  ItemPaging?)(chanels : Array<TVGridChannel>?) -> TVGrid {
        return TVGrid(paging:paging,chanels:chanels)
    }
    
    static func decode(json: JSON) -> TVGrid? {
        return _JSONObject(json) >>> { d in
            TVGrid.create <^>
                ItemPaging.decode(_JSONObject(d["paging"])) <*>
                _JSONArray(d["grid"]) >>> { c in
                    var array = Array<TVGridChannel>()
                    for channelData in c {
                        let channel = TVGridChannel.decode(channelData)
                        array.append(channel!)
                    }
                    return array
                }
        }
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
            guard paging != nil else {
                return 0
            }
            return paging!.pageNumber
        }
    }
    
    var totalPages : Int {
        get{
            guard paging != nil else {
                return 0
            }
            return paging!.totalPages
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
    
}
