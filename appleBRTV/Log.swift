//
//  Log.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/2/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit
extension NSDate{
    func toLogString() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timeString = formatter.stringFromDate(self)
        return timeString
    }
}
class Log {
    class func d(message: String,
       let functionName:  String = __FUNCTION__, fileNameWithPath: String = __FILE__, lineNumber: Int = __LINE__ ) {
            let fpath = NSURL(fileURLWithPath: fileNameWithPath).URLByDeletingPathExtension
            let fileNameWithoutPath = fpath!.lastPathComponent
            let output = "\(NSDate().toLogString()) \(fileNameWithoutPath!)(\(lineNumber)) \(functionName) :  \(message)"
            print(output)
    }
}
