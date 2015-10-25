//
//  BRTVAPITests.swift
//  appleBRTV
//
//  Created by Aleksandr Kelbas on 10/10/2015.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import XCTest


class BRTVAPITests: XCTestCase , TVGridDataSourceDelegate{
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_00_BRTVAPI()
    {
        XCTAssertNotNil(BRTVAPI.sharedInstance, "Cannot find BRTVAPI's shared instace")
        
    }
    
    func test_00_BRTVAPILogin()
    {
        let expectation = expectationWithDescription("Connected to BRTV server")
        
        let username = "igorkos"
        let password = "rutv12"
        
        BRTVAPI.sharedInstance.login(username, password: password, completion: {
            (response: AnyObject?, error: ErrorType?) in
          
            XCTAssertNil(error, "There was an error returned by the API handler")
            
            let settings = response as? ClientAppSettings
            XCTAssertNotNil(settings, "Response object is nil")
            
            XCTAssertNotNil(settings!.clientCredentials, "Response doesn't contain client credentials information")
            XCTAssertNotNil(settings!.sessionID, "Response doesn't containc client session ID")
            print("SessionID: \(settings!.sessionID)")
            
            expectation.fulfill()
        })

        
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            
            XCTAssertNil(error, "Failed to connect to BRTV server")
            
        })
        
    }
    
    
    func test_01_BRTVAPIGetChannels()
    {
        let expectation = expectationWithDescription("Did get channels")
        
        BRTVAPI.sharedInstance.getClientChannels( { (response: AnyObject?, error: ErrorType?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
           
            XCTAssert(response is BRTVResponseObject, "Response format is incorrect")
            
            let channels =  (response as! BRTVResponseObject).response as! Dictionary<String,AnyObject>
            XCTAssertNotNil(channels["items"], "Response doesn't contain channel items")
            
            expectation.fulfill()
        })
        //"bd0320a5d0131fa3fe1899f7d1feef2d",
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }
    
    func test_02_BRTVAPIGetTVGrid()
    {
        let expectation = expectationWithDescription("Did get tvgrid")
        let start = NSDate(timeIntervalSinceNow:-1800)
        let end  = NSDate(timeIntervalSinceNow:18000)

        BRTVAPI.sharedInstance.getClientTVGrid(start ,end: end ,page: 1, completion: { (response: AnyObject?, error: ErrorType?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is TVGrid, "Response format is incorrect")
            expectation.fulfill()
        })
        //"bd0320a5d0131fa3fe1899f7d1feef2d",
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }

    func test_03_BRTVAPIGetArchiveChannels()
    {
        let expectation = expectationWithDescription("Did get channels")
        
        BRTVAPI.sharedInstance.getClientArchiveChannels( { (response: AnyObject?, error: ErrorType?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is BRTVResponseObject, "Response format is incorrect")
            
            let channels =  (response as! BRTVResponseObject).response as! Dictionary<String,AnyObject>
            
            XCTAssertNotNil(channels["items"], "Response doesn't contain channel items")
            
            expectation.fulfill()
        })
        //"bd0320a5d0131fa3fe1899f7d1feef2d",
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }

    
    
    func test_04_BRTVAPIGetURI()
    {
        let expectation = expectationWithDescription("did get uri")
        
        BRTVAPI.sharedInstance.getStreamURI(24,  completion: { (response: AnyObject?, error: ErrorType?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is BRTVResponseObject, "Response format is incorrect")
            
            let url =  (response as! BRTVResponseObject).response as! Dictionary<String,AnyObject>
            XCTAssertNotNil(url["URL"], "Response doesn't contain uri")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }
    
    func test_05_BRTVAPIGetImageURI()
    {
        let expectation = expectationWithDescription("did get GetImageURI")
        
        BRTVAPI.sharedInstance.getImageURIs(1, mediaType: .ChanelLogoTransparent, index: 1, completion: { (response: AnyObject?, error: ErrorType?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }
    
    func test_06_BRTVAPIgetMediaImageType()
    {
        let expectation = expectationWithDescription("did get MediaImageType")
        
        BRTVAPI.sharedInstance.getMediaImageType( { (response: AnyObject?, error: ErrorType?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            print("response: \(response!)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }
    
    func test_07_BRTVAPIgetMediaZoneInfo()
    {
        let expectation = expectationWithDescription("did get MediaZoneInfo")
        
        BRTVAPI.sharedInstance.getMediaZoneInfo( { (response: AnyObject?, error: ErrorType?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            print("response: \(response!)")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
    }

    func loadGrid(page:Int) -> TVGrid?{
        
        let expectation = expectationWithDescription("did get TVGridFullLoad")
        
        let start = NSDate(timeIntervalSinceNow:-1800)
        let end  = NSDate(timeIntervalSinceNow:18000)
        var data : TVGrid? = nil
        
        BRTVAPI.sharedInstance.getClientTVGrid(start ,end: end ,page: page, completion: { (response: AnyObject?, error: ErrorType?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is TVGrid, "Response format is incorrect")
            data = response as? TVGrid
           // print(response)
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
        return data
    }
    
    func test_08_BRTVAPIGetTVGridFullLoad()
    {
        var tvgrid : TVGrid? = nil
        var nextPage = 1
        repeat{
            let response = loadGrid(nextPage++)
            guard tvgrid != nil else{
                tvgrid = response
                continue
            }
            tvgrid! += response!
        }while(tvgrid?.page != tvgrid?.totalPages)
        
        XCTAssertEqual(tvgrid?.count, tvgrid?.paging?.totalItems)
      //  print("loaded \(tvgrid.count) chanels")
        
    }
    
    func test_09_BRTVAPIUpdateTVGrid()
    {
        var tvgrid : TVGrid? = nil
        var expectation = expectationWithDescription("Did get tvgrid")
        var start = NSDate(timeIntervalSinceNow:-1800)
        var end  = NSDate(timeIntervalSinceNow:18000)
        
        BRTVAPI.sharedInstance.getClientTVGrid(start ,end: end ,page: 1, completion: { (response: AnyObject?, error: ErrorType?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is TVGrid, "Response format is incorrect")
            tvgrid = response as? TVGrid
            expectation.fulfill()
        })
        //"bd0320a5d0131fa3fe1899f7d1feef2d",
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
        
        let programsCount = tvgrid?.chanels![0].count
        
        expectation = expectationWithDescription("Did get tvgrid")
        start = end
        end = NSDate(timeInterval:18000 , sinceDate: start)
        BRTVAPI.sharedInstance.getClientTVGrid(start ,end: end ,page: 1, completion: { (response: AnyObject?, error: ErrorType?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is TVGrid, "Response format is incorrect")
            tvgrid! += (response as? TVGrid)!
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
        XCTAssertGreaterThanOrEqual((tvgrid?.chanels![0].count)!,programsCount!)
    }

    func test_10_BRTVAPITVGridDataSource()
    {
        var tvgrid : TVGrid? = nil
        var expectation = expectationWithDescription("Did get tvgrid")
        var start = NSDate(timeIntervalSinceNow:-1800)
        var end  = NSDate(timeIntervalSinceNow:18000)
        
        BRTVAPI.sharedInstance.getClientTVGrid(start ,end: end ,page: 1, completion: { (response: AnyObject?, error: ErrorType?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is TVGrid, "Response format is incorrect")
            tvgrid = response as? TVGrid
            expectation.fulfill()
        })
        //"bd0320a5d0131fa3fe1899f7d1feef2d",
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
        
        let programsCount = tvgrid?.chanels![0].count
        
        expectation = expectationWithDescription("Did get tvgrid")
        start = end
        end = NSDate(timeInterval:18000 , sinceDate: start)
        BRTVAPI.sharedInstance.getClientTVGrid(start ,end: end ,page: 1, completion: { (response: AnyObject?, error: ErrorType?) in
            XCTAssertNil(error, "There was an error returned by the API handler")
            XCTAssertNotNil(response, "Response object is nil")
            XCTAssert(response is TVGrid, "Response format is incorrect")
            tvgrid! += (response as? TVGrid)!
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(3000, handler: { (error: ErrorType?) in
            XCTAssertNil(error, "Failed to connect to BRTV server")
        })
        XCTAssertGreaterThanOrEqual((tvgrid?.chanels![0].count)!,programsCount!)
    }

    
    //MARK: - TVGridDataSourceDelegate
    var expectationUpdateTVGrid : XCTestExpectation?
    
    func tvGridDataSource(tvGridDataSource: TVGridDataSource, updateChanelsData page: Int, count: Int){
        
    }
    
    func tvGridDataSource(tvGridDataSource: TVGridDataSource, didUpdateChanelsData count: Int){
        expectationUpdateTVGrid!.fulfill()
    }
    
    func tvGridDataSource(tvGridDataSource: TVGridDataSource, didGetError: ErrorType){
        
    }
}
