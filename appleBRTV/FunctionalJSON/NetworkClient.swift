import Foundation
import Argo
import Curry
import Runes

precedencegroup ExponentiationPrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator >>>  : ExponentiationPrecedence

func >>><A, B>(a: A?, f: (A) -> B?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .none
    }
}

func >>><A, B>(a: Result<A>, f: (A) -> Result<B>) -> Result<B> {
    switch a {
    case let .value(x):     return f(x)
    case let .error(error): return .error(error)
    }
}


public typealias APIResponseBlock = ((_ response: AnyObject?, _ error: Error?) -> ())

func performRequest<A>(_ request: NSMutableURLRequest, jsonObject: AnyObject?, result:A.Type, completion: @escaping APIResponseBlock) {
    request.httpMethod = "POST"
    request.httpBody = encodeJSON(data: jsonObject)
    
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.httpAdditionalHeaders = ["Content-Type" : "application/json"]
    let session = URLSession(configuration: sessionConfig)
    
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, urlResponse, error in
        let result : Result<A> = parseResult(data, urlResponse: urlResponse, error: error as NSError!)
        switch result {
        case let .error(error):
            completion(nil, error)
        case let .value(response):
            completion(response as? AnyObject, nil)
        }

    }) 
    task.resume()
}

func parseResult<A>(_ data: Data!, urlResponse: URLResponse!, error: NSError!) -> Result<A> {
    let responseResult: Result<Response> = Result(error, Response(data: data, urlResponse: urlResponse))
    return responseResult >>> parseResponse
                          >>> decodeJSON
                          >>> decodeObject
}

func parseResponse(_ response: Response) -> Result<Data> {
    let successRange = 200..<300
    if !successRange.contains(response.statusCode) {
        Log.d("Error - \(String(describing: NSString(data: response.data, encoding:String.Encoding.utf8.rawValue)))")
        return .error(NSError(domain: "JSON",code:response.statusCode, userInfo: nil)) // customize the error message to your liking
    }
    return Result(nil, response.data)
}

func encodeJSON(data: AnyObject?) -> Data? {
    guard data != nil else {
        return nil
    }
    let jsonOptional = try? JSONSerialization.data(withJSONObject: data!, options: [])
    return jsonOptional
}

func decodeJSON(data: Data) -> Result<JSON> {
    var jsonOptional: JSON? = nil
    do{
        jsonOptional = try JSONSerialization.jsonObject(with: data as Data, options: [])
    }
    catch  {
        let s = String(data: data as Data, encoding: String.Encoding.utf8)
        return resultFromOptional( s, error: NSError(domain: "JSON",code:-1, userInfo: nil))
    }
    return resultFromOptional(jsonOptional, error: NSError(domain: "JSON",code:-1, userInfo: nil)) // use the error from NSJSONSerialization or a custom error message
}

func decodeObject<А>(json: JSON) -> Result<А> {
    return resultFromOptional(А.decode(json) as? (A), error: NSError(domain: "JSON",code:-2, userInfo: nil))
}
