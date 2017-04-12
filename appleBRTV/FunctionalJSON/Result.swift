import Foundation

enum Result<A> {
    case error(Error)
    case value(A)

    init(_ error: Error?, _ value: A) {
        if let err = error {
            self = .error(err)            
        } else {
            self = .value(value)
        }
    }
}

func resultFromOptional<A>(_ optional: A?, error: NSError?) -> Result<A> {
    if let a = optional {
        return .value(a)
    } else {
        let err = error
        return .error(err!)
    }
}

