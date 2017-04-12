//
//  NSDate+Compomets.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 10/16/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation

func >(first:Date,second:Date) -> Bool{
    switch first.compare(second) {
    case .orderedAscending:
        return false
    case .orderedDescending:
        return true
    case .orderedSame:
        return false
    }
}

func >=(first:Date,second:Date) -> Bool{
    switch first.compare(second) {
    case .orderedAscending:
        return false
    case .orderedDescending:
        return true
    case .orderedSame:
        return true
    }
}

func <(first:Date,second:Date) -> Bool{
    switch first.compare(second) {
    case .orderedAscending:
        return true
    case .orderedDescending:
        return false
    case .orderedSame:
        return false
    }
}

func <=(first:Date,second:Date) -> Bool{
    switch first.compare(second) {
    case .orderedAscending:
        return true
    case .orderedDescending:
        return false
    case .orderedSame:
        return true
    }
}

func ==(first:Date,second:Date) -> Bool{
    switch first.compare(second) {
    case .orderedAscending:
        return false
    case .orderedDescending:
        return false
    case .orderedSame:
        return true
    }
}

func -(first:Date,second:Date) -> TimeInterval{
    let sec = first.timeIntervalSince(second)
    return sec
}

func +=( left:inout Date,right:TimeInterval) -> Date{
    left = Date(timeInterval: right, since: left)
    return left
}

func +( left:Date,right:TimeInterval) -> Date{
    let date = Date(timeInterval: right, since: left)
    return date
}


extension Date
{
    //Get Hour
    func hour() -> Int
    {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.hour, from: self)
        let hour = components.hour
        return hour!
    }

    //Get day
    func day() -> Int
    {
        let calendar = Calendar.current
        let day = (calendar as NSCalendar).ordinality(of: .day, in: .year, for: self)
        return day
    }
    
    //Get year
    func year() -> Int
    {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.year, from: self)
        let year = components.year
        return year!

    }

    //Get Minute
    func minute() -> Int
    {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.minute, from: self)
        let minute = components.minute
        return minute!
    }
    
    //Get closest fraction
    func closestTo(_ part: Int) -> Date
    {
        let min = self.minute()
        let over = min % part
        return Date(timeInterval: Double(0-over*60), since: self)
    }
    
    //Get Short Time String
    func toShortTimeString() -> String
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: self)
        return timeString
    }

    func toDateString() -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM.dd"
        let timeString = formatter.string(from: self)
        return timeString
    }

    
    func toTimeString() -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: self)
        return timeString
    }

    public init( value : String ) {
        guard value.characters.count > 0 else{
            self.init()
            return
        }
        let start = value.range(of: "Date(")!.upperBound
        let end = value.range(of: ")")!.lowerBound
        let range = (start ..< end)
        let sec = Double(value.substring(with: range))!/1000
        self.init(timeIntervalSince1970: sec)
    }
    
}
