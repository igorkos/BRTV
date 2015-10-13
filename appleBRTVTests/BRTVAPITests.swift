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
    
    var sessionID: String? = nil
    
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
        
        let username = ""
        let password = ""
        
        BRTVAPI.sharedInstance.login(username, password: password, completion: {
            (response: AnyObject?, error: NSError?) in
            
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is NSDictionary, "Response format is incorrect")
            
            XCTAssertNotNil(response!["clientCredentials"], "Response doesn't contain client credentials information")
            XCTAssertNotNil(response!["clientCredentials"]!!["sessionID"], "Response doesn't containc client session ID")
            
            
            let res = (response as! NSDictionary)
            let cred = res["clientCredentials"] as! NSDictionary
            
            self.sessionID = (cred["sessionID"] as! String)
            
            print("SessionID: \(self.sessionID)")
            
            expectation.fulfill()
        })

        
        waitForExpectationsWithTimeout(30, handler: { (error: NSError?) in
            
            XCTAssertNil(error, "Failed to connect to BRTV server")
            
        })
        
    }
    
    
    func testBRTVAPIGetChannels()
    {
        let expectation = expectationWithDescription("Did get channels")
        
        BRTVAPI.sharedInstance.getClientChannels("bd0320a5d0131fa3fe1899f7d1feef2d", completion: { (response: AnyObject?, error: NSError?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is NSDictionary, "Response format is incorrect")
            
            XCTAssertNotNil(response!["items"], "Response doesn't contain channel items")

            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(30, handler: { (error: NSError?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }
    
    func testBRTVAPIGetURI()
    {
        let expectation = expectationWithDescription("did get uri")
        
        BRTVAPI.sharedInstance.getStreamURI(24, sessionID: "bd0320a5d0131fa3fe1899f7d1feef2d", completion: { (response: AnyObject?, error: NSError?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is NSDictionary, "Response format is incorrect")
            
            XCTAssertNotNil(response!["URL"], "Response doesn't contain channel items")
            print("response: \(response!)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(30, handler: { (error: NSError?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }
}
