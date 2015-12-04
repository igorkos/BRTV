protocol JSONDecodable {
    typealias ItemType
    static func arrayKey() ->String
    static func decode(json: JSON) -> ItemType?
}
