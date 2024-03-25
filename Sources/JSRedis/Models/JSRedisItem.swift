import Foundation

protocol JSRedisItem {
    var expiration: Date? { get }
}

public struct JSRedisStringItem: JSRedisItem {
    // MARK: Init
    public init(key: String, value: String, expiration: Date? = nil) {
        self.key = key
        self.value = value
        self.expiration = expiration
    }
    
    // MARK: Properties
    public let key: String
    public let value: String
    public let expiration: Date?

    // MARK: Enum Type
    public enum JSRedisItemType {
        case string(String)
        case dictionary([String: String])
    }
}
