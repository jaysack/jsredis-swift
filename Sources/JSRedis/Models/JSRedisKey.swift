import Foundation
import Redis

public struct JSRedisKey {
    // MARK: Properties
    public let key: String
    public let expiration: JSExpiration?
    
    // MARK: Init
    public init(key: String, expiration: JSExpiration? = nil) {
        self.key = key
        self.expiration = expiration
    }

    // MARK: Redis Key
    func redisKey() -> RedisKey {
        return RedisKey(key)
    }
}
