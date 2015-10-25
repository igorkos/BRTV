infix operator >>> { associativity left precedence 170 } // bind

infix operator <^> { associativity left } // Functor's fmap (usually <$>)
infix operator <*> { associativity left } // Applicative's apply


func >>><A, B>(a: A?, f: A -> B?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .None
    }
}

func >>><A, B>(a: Result<A>, f: A -> Result<B>) -> Result<B> {
    switch a {
    case let .Value(x):     return f(x)
    case let .Error(error): return .Error(error)
    }
}

func <^><A, B>(f: A -> B, a: A) -> B {
    return f(a)
}

func <*><A, B>(f: (A -> B), a: A) -> B {
    return f(a)
}
