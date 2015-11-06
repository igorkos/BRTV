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

}
