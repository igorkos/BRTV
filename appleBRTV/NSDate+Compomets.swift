//
//  NSDate+Compomets.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/16/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation

extension NSDate
{
    //Get Hour
    func hour() -> Int
    {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: self)
        let hour = components.hour
        return hour
    }
    
    //Get Minute
    func minute() -> Int
    {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Minute, fromDate: self)
        let minute = components.minute
        return minute
    }
    
    //Get closest fraction
    func closestTo(part: Int) -> NSDate
    {
        let min = self.minute()
        let over = min % part
        return NSDate(timeInterval: Double(0-over*60), sinceDate: self)
    }
    
    //Get Short Time String
    func toShortTimeString() -> String
    {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let timeString = formatter.stringFromDate(self)
        return timeString
    }

    func toTimeString() -> String
    {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .FullStyle
        let timeString = formatter.stringFromDate(self)
        return timeString
    }

    public convenience init( value : String ) {
        let start = value.rangeOfString("Date(")!.endIndex
        let end = value.rangeOfString(")")!.startIndex
        let range = Range(start: start, end: end)
        let sec = Double(value.substringWithRange(range))!/1000
        self.init(timeIntervalSince1970: sec)
    }
    
}