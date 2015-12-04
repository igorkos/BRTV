//
//  NSDateOperators.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/6/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import XCTest

class NSDateOperators: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test() {
        let date2 = NSDate()
        let date1 = NSDate(timeInterval: -30, sinceDate: date2)
        let date3 = NSDate(timeInterval: 30, sinceDate: date2)
        XCTAssertTrue(date3 > date2)
        XCTAssertTrue(date3 > date1)
        XCTAssertTrue(date2 > date1)
        
        XCTAssertTrue(date3 >= date2)
        XCTAssertTrue(date3 >= date1)
        XCTAssertTrue(date2 >= date1)
        XCTAssertTrue(date2 >= date2)
        
        XCTAssertTrue(date1 < date2)
        XCTAssertTrue(date1 < date3)
        XCTAssertTrue(date2 < date3)
        
        XCTAssertTrue(date1 <= date2)
        XCTAssertTrue(date1 <= date3)
        XCTAssertTrue(date2 <= date3)
        XCTAssertTrue(date2 <= date2)

        XCTAssertTrue(date1 == date1)
        XCTAssertTrue(date2 == date2)
        XCTAssertTrue(date3 == date3)
    }
    
    func test0(){
        let date = DateTime(input: "/Date(-62135578800000-0500)/")
        Log.d("Date: \(date)")
    }
    
    func test1(){
        let now = DateTime()
        let zone = Zone("Europe/Moscow")!
        Log.d("Zone: \(zone) offset: \(zone.secondsFromUTC)")
        
        let end = now.inZone(Zone("Europe/Moscow")!)
        Log.d("now: \(now) zone: \(end)")
        
        var date = NSDate(timeIntervalSince1970: Double(now.milisecondsSince1970))
         Log.d("\(date)")
        
        date = NSDate(timeIntervalSince1970: Double(end.milisecondsSince1970) + Double(zone.secondsFromUTC))
        Log.d("\(date)")
    }
}
