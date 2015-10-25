import Foundation

typealias JSON = AnyObject
typealias JSONDictionary = Dictionary<String, AnyObject>
typealias JSONArray = Array<AnyObject>

func _JSONString(object: JSON?) -> String {
    guard let value = object as? String else {
        return String()
    }
    return value
}

func _JSONInt(object: JSON?) -> Int {
    guard let value = object as? Int else {
        return Int(0)
    }
    return value
}

func _JSONBool(object: JSON?) -> Bool {
    guard let value = object as? Bool else {
        return Bool(false)
    }
    return value
}


func _JSONObject(object: JSON?) -> JSONDictionary {
    guard let value = object as? JSONDictionary else {
        return JSONDictionary()
    }
    return value
}

func _JSONAnyObject(object: JSON) -> JSON? {
    return object
}

func _JSONArray(object: JSON?) -> JSONArray {
    guard let value = object as? JSONArray else {
        return JSONArray()
    }
    return value
}

func encodeJSON(data: AnyObject?) -> NSData? {
    guard data != nil else {
        return nil
    }
    let jsonOptional: NSData! = try? NSJSONSerialization.dataWithJSONObject(data!, options: [])
    return jsonOptional
}


func decodeJSON(data: NSData) -> Result<JSON> {
    var jsonOptional: JSON? = nil
    do{
        jsonOptional = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
    }
    catch  {
        let s = String(data: data, encoding: NSUTF8StringEncoding)
        return resultFromOptional( s, error: NSError(domain: "JSON",code:-1, userInfo: nil))
    }
    return resultFromOptional(jsonOptional, error: NSError(domain: "JSON",code:-1, userInfo: nil)) // use the error from NSJSONSerialization or a custom error message
}

func decodeObject<U: JSONDecodable>(json: JSON) -> Result<U> {
    return resultFromOptional(U.decode(json) as? U, error: NSError(domain: "JSON",code:-2, userInfo: nil))
}
