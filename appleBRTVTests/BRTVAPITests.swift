//
//  BRTVAPITests.swift
//  appleBRTV
//
//  Created by Aleksandr Kelbas on 10/10/2015.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import XCTest
@testable import appleBRTV

class BRTVAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBRTVAPISetup()
    {
        XCTAssertNotNil(BRTVAPI.sharedInstance, "Cannot find BRTVAPI's shared instace")
        
    }
    
    func testBRTVAPILogin()
    {
        let expectation = expectationWithDescription("Connected to BRTV server")
        
        BRTVAPI.sharedInstance.login("scapegracer", password: "cinnamon", completion: {
            (response: AnyObject?, error: NSError?) in
            
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is NSDictionary, "Response format is incorrect")
            
            XCTAssertNotNil(response!["clientCredentials"], "")
            
            
            
            
            expectation.fulfill()
        })

        
        waitForExpectationsWithTimeout(10, handler: { (error: NSError?) in
            
            XCTAssert(error != nil, "Failed to connect to BRTV server")
            
        })
        
    }
}
