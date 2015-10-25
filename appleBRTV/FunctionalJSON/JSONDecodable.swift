protocol JSONDecodable {
    typealias ItemType
    static func decode(json: JSON) -> ItemType?
}
