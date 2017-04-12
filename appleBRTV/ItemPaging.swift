//
//  ItemPaging.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 4/12/17.
//  Copyright © 2017 Aleksandr Kelbas. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

class ItemPaging {
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
    
    static func create(_ itemsOnPage : Int, _ pageNumber  : Int, _ totalItems : Int, _ totalPages : Int) -> ItemPaging {
        return ItemPaging(itemsOnPage: itemsOnPage, pageNumber: pageNumber,totalItems: totalItems,totalPages: totalPages)
    }
    
    static func decode(_ json: JSON) -> Decoded<ItemPaging>? {
        return curry( ItemPaging.init )
            <^> json <| "itemsOnPage"
            <*> json <| "pageNumber"
            <*> json <| "totalItems"
            <*> json <| "totalPages"
    }
    
    static func arrayKey() ->String{
        return ""
    }
}
