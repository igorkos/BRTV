import Foundation

public typealias APIResponseBlock = ((response: AnyObject?, error: ErrorType?) -> ())

func performRequest<A: JSONDecodable>(request: NSMutableURLRequest, jsonObject: AnyObject?, result:A.Type, completion: APIResponseBlock) {
    request.HTTPMethod = "POST"
    request.HTTPBody = encodeJSON(jsonObject)
    
    let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    sessionConfig.HTTPAdditionalHeaders = ["Content-Type" : "application/json"]
    let session = NSURLSession(configuration: sessionConfig)
    
    let task = session.dataTaskWithRequest(request) { data, urlResponse, error in
        let result : Result<A> = parseResult(data, urlResponse: urlResponse, error: error)
        switch result {
        case let .Error(error):
            completion(response: nil, error: error)
        case let .Value(response):
            completion(response: response as? AnyObject, error: nil)
        }

    }
    task.resume()
}

func parseResult<A: JSONDecodable>(data: NSData!, urlResponse: NSURLResponse!, error: NSError!) -> Result<A> {
    let responseResult: Result<Response> = Result(error, Response(data: data, urlResponse: urlResponse))
    
    return responseResult >>> parseResponse
                          >>> decodeJSON
                          >>> decodeObject
}

func parseResponse(response: Response) -> Result<NSData> {
    let successRange = 200..<300
    if !successRange.contains(response.statusCode) {
        return .Error(NSError(domain: "JSON",code:response.statusCode, userInfo: nil)) // customize the error message to your liking
    }
    return Result(nil, response.data)
}
