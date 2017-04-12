//
//  TVGridDataSourceDelegate.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 2/6/17.
//  Copyright © 2017 Aleksandr Kelbas. All rights reserved.
//

import Foundation

protocol TVGridDataSourceDelegate : NSObjectProtocol{
    func tvGridDataSource(_ tvGridDataSource: TVGridDataSource, didChangeObjects: NSRange)
    func controllerWillChangeContent(_ tvGridDataSource: TVGridDataSource )
    func controllerDidChangeContent(_ tvGridDataSource: TVGridDataSource )
    func tvGridDataSource(_ tvGridDataSource: TVGridDataSource, didGetError: Error)
}
