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
    
    func test_00_BRTVAPILogin()
    {
        let expectation = expectationWithDescription("Connected to BRTV server")
        
        let username = "igorkos"
        let password = "rutv12"
        
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
    
    
    func test_01_BRTVAPIGetChannels()
    {
        let expectation = expectationWithDescription("Did get channels")
        
        BRTVAPI.sharedInstance.getClientChannels( { (response: AnyObject?, error: NSError?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is NSDictionary, "Response format is incorrect")
            
            XCTAssertNotNil(response!["items"], "Response doesn't contain channel items")
         //   print(response)
            
            expectation.fulfill()
        })
        //"bd0320a5d0131fa3fe1899f7d1feef2d",
        waitForExpectationsWithTimeout(30, handler: { (error: NSError?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }
    
    func test_02_BRTVAPIGetTVGrid()
    {
        let expectation = expectationWithDescription("Did get tvgrid")
        let start = NSDate(timeIntervalSinceNow:-1800)
        let end  = NSDate(timeIntervalSinceNow:18000)

        BRTVAPI.sharedInstance.getClientTVGrid(start ,end: end ,page: 1, completion: { (response: AnyObject?, error: NSError?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is NSDictionary, "Response format is incorrect")
            print(response)
//            XCTAssertNotNil(response!["items"], "Response doesn't contain channel items")
            
            
            expectation.fulfill()
        })
        //"bd0320a5d0131fa3fe1899f7d1feef2d",
        waitForExpectationsWithTimeout(30, handler: { (error: NSError?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }

    func test_03_BRTVAPIGetArchiveChannels()
    {
        let expectation = expectationWithDescription("Did get channels")
        
        BRTVAPI.sharedInstance.getClientArchiveChannels( { (response: AnyObject?, error: NSError?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            if response != nil {
                XCTAssert(response is NSDictionary, "Response format is incorrect")
                XCTAssertNotNil(response!["items"], "Response doesn't contain channel items")
           //     print(response)
            }
            
            
            expectation.fulfill()
        })
        //"bd0320a5d0131fa3fe1899f7d1feef2d",
        waitForExpectationsWithTimeout(30, handler: { (error: NSError?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }

    
    
    func test_04_BRTVAPIGetURI()
    {
        let expectation = expectationWithDescription("did get uri")
        
        BRTVAPI.sharedInstance.getStreamURI(24,  completion: { (response: AnyObject?, error: NSError?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is NSDictionary, "Response format is incorrect")
            
            XCTAssertNotNil(response!["URL"], "Response doesn't contain channel items")
        //    print("response: \(response!)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(30, handler: { (error: NSError?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }
    
    func test_05_BRTVAPIGetImageURI()
    {
        let expectation = expectationWithDescription("did get GetImageURI")
        
        BRTVAPI.sharedInstance.getImageURIs(1, mediaType: .ChanelLogoTransparent, index: 1, completion: { (response: AnyObject?, error: NSError?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            print("response: \(response!)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(30, handler: { (error: NSError?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }
    
    func test_06_BRTVAPIgetMediaImageType()
    {
        let expectation = expectationWithDescription("did get MediaImageType")
        
        BRTVAPI.sharedInstance.getMediaImageType( { (response: AnyObject?, error: NSError?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            print("response: \(response!)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(30, handler: { (error: NSError?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }
    
    func test_07_BRTVAPIgetMediaZoneInfo()
    {
        let expectation = expectationWithDescription("did get MediaZoneInfo")
        
        BRTVAPI.sharedInstance.getMediaZoneInfo( { (response: AnyObject?, error: NSError?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            print("response: \(response!)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(30, handler: { (error: NSError?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }

    func loadGrid(page:Int) -> [String:AnyObject]?{
        
        let expectation = expectationWithDescription("did get TVGridFullLoad")
        
        let start = NSDate(timeIntervalSinceNow:-1800)
        let end  = NSDate(timeIntervalSinceNow:18000)
        var data : [String:AnyObject]? = nil
        
        BRTVAPI.sharedInstance.getClientTVGrid(start ,end: end ,page: page, completion: { (response: AnyObject?, error: NSError?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is NSDictionary, "Response format is incorrect")
            
            print(response)
            data = response as? [String:AnyObject]
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(30, handler: { (error: NSError?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
        return data
    }
    
    func test_08_BRTVAPIGetTVGridFullLoad()
    {
        let tvgrid : TVGrid = TVGrid()
        var nextPage = 1
        repeat{
            let response = loadGrid(nextPage++)
            let paging = tvgrid.updateGrid(response!)
            print(paging)
            if paging.totalPages == paging.page{
                break
            }
        }while(true)
        
        print("loaded \(tvgrid.paging![.totalPages]) pages with \(tvgrid.count) chanels")
        
    }
}
