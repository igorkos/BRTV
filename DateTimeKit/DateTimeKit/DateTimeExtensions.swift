//
//  DateTimeExtensions.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/8/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import Foundation

extension DateTime {
    
    public init?(input: String,zone: Zone = Zone.systemDefault(), error: DateTimeErrorPointer? = nil){
        let start = input.range(of: "Date(")!.upperBound
        let end = input.range(of: ")")!.lowerBound
        let range = (start ..< end)
        var dateString = input.substring(with: range)
        //-62135578800000-0500
        var timeZone = zone
        if dateString.characters.count > 14 {
            //time zone
            let index = dateString.characters.index(dateString.endIndex, offsetBy: -5)
            let zoneString = dateString.substring(from: index)
            timeZone = Zone(zoneString)!
            dateString = dateString.substring(to: index)
        }
        let index = dateString.characters.index(dateString.endIndex, offsetBy: -3)
        dateString = dateString.substring(to: index)
        var date: AnyObject?
        date = Date(timeIntervalSince1970: Double(dateString)!) as AnyObject?
        self.init(Instant(date as! Date), timeZone)
    }
    
    public init(lastPeriodMark: Int,zone: Zone = Zone.systemDefault(), error: DateTimeErrorPointer? = nil){
        var time = DateTime(Instant(),zone)
        let min = time.minute
        var diff : Double = Double(min % lastPeriodMark)
        diff = diff*60.0 + Double(time.second)
        time = time.minus(Duration(diff))
        self.init(time.instant(),zone)
    }
    

    public var secondsSince1970: Int { get { return Int(instant().asNSDate().timeIntervalSince1970)} }
    
    public var milisecondsSince1970: Int { get { return self.secondsSince1970*1000 } }
    
    func secondsSince1970(_ zone:Zone) -> Int{
        return self.secondsSince1970+zone.secondsFromUTC
    }
    
    func milisecondsSince1970(_ zone:Zone) -> Int{
        return self.milisecondsSince1970+zone.secondsFromUTC*1000
    }

    public func lastPeriodMark( _ mark : Int ) -> DateTime {
        let min = self.minute
        var diff : Double = Double(min % mark)
        diff = diff*60.0 + Double(self.second) + Double(self.millisecond)/100.0
        return self.minus(Duration(diff))
    }
    
    public func toJsonDateString() -> String {
        return "/Date(\(self.milisecondsSince1970))/"
    }
    
    public func toShortString() -> String {
        return String(format: "%02d:%02d",self.hour,self.minute)
    }
    
    public func toShortDateString() -> String {
        return String(format: "%02d:%02d",self.day,self.month)
    }
}

public func + (lhs: DateTime, rhs: Int) -> DateTime {
    return lhs.plus(Duration(rhs))
}
public func - (lhs: DateTime, rhs: Int) -> DateTime {
    return lhs.minus(Duration(rhs))
}

public func - (lhs: DateTime, rhs: DateTime) -> Duration {
    return Duration(lhs.secondsSince1970 - rhs.secondsSince1970)
}

public func +=(lhs: inout DateTime, rhs: Int) -> DateTime {
    lhs = lhs + rhs
    return lhs
}

public func -=(lhs: inout DateTime, rhs: Int) -> DateTime {
    lhs = lhs - rhs
    return lhs
}

extension Zone {
    var secondsFromUTC : Int {
        get { return timezone.secondsFromGMT() }
    }
}
