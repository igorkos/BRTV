//
//  Log.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/2/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit
extension Date{
    func toLogString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timeString = formatter.string(from: self)
        return timeString
    }
}
open class Log {
    class func d(_ message: String,
       functionName:  String = #function, fileNameWithPath: String = #file, lineNumber: Int = #line ) {
            let fpath = NSURL(fileURLWithPath: fileNameWithPath).deletingPathExtension
            let fileNameWithoutPath = fpath!.lastPathComponent
            let output = "\(Date().toLogString()) \(fileNameWithoutPath)(\(lineNumber)) \(functionName) :  \(message)"
            print(output)
    }
}
