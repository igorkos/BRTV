import Foundation

enum Result<A> {
    case Error(ErrorType)
    case Value(A)

    init(_ error: ErrorType?, _ value: A) {
        if let err = error {
            self = .Error(err)
        } else {
            self = .Value(value)
        }
    }
}

func resultFromOptional<A>(optional: A?, error: NSError?) -> Result<A> {
    if let a = optional {
        return .Value(a)
    } else {
        let err = error
        return .Error(err!)
    }
}

