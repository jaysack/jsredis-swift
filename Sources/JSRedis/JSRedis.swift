import Redis
import Vapor

public final class JSRedis {

    // MARK: Init
    private init() {
        
    }

    // MARK: Properties
    public static let shared = JSRedis()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    // MARK: - ITEM Methods
    // SET
    public func set<T: Codable>(_ value: T, for key: JSRedisKey, on req: Request) async throws {
        // Save expiration date (if provided)
        if let expiration = key.expiration {
            try await req.redis.setex(key.redisKey(), toJSON: value, expirationInSeconds: Int(expiration.duration))
        // Else
        } else {
            try await req.redis.set(key.redisKey(), toJSON: value).get()
        }
        // Log result
        req.logger.debug("💾 Redis item saved: '\(key)'")
    }

    // GET
    public func get<T: Codable>(_ key: String, on req: Request) async throws -> T? {
        let item = try await req.redis.get(key.redisKey(), asJSON: T.self)
        req.logger.debug("💾 Redis item retrieved: '\(key)'")
        return item
    }

    // DEL
    public func del(_ keys: [String], on req: Request) async throws -> Int {
        let redisKeys = keys.map { $0.redisKey() }
        let result = try await req.redis.delete(redisKeys).get()
        req.logger.debug("💾 Redis items deleted: \(keys.joined(separator: ", "))")
        return result
    }

    // MARK: - SET Methods
    // SADD
    public func sAdd<T: Codable>(_ member: T, to key: String, expiration: JSExpiration? = nil, on req: Request) async throws {
        // Encode member value
        let element = try encoder.encode(member).base64EncodedString()
        // Save expiration date (if provided)
        if let expiration {
            let redisKey = JSRedisKey(key: "exp::\(key)::\(element)", expiration: nil)
            let expirationDate = Date().addingTimeInterval(expiration.duration)
            try await set(expirationDate, for: redisKey, on: req)
            req.logger.debug("💾 Redis item expiration: '\(key)' member of type \(member.self) will expire on \(expirationDate.rfc1123)")
        }
        // Add element to set
        let _ = try await req.redis.sadd([element], to: key.redisKey()).get()
        req.logger.debug("💾 Redis item added: '\(key)' member of type \(member.self) was added")
    }

    // SISMEMBER
    public func sIsMember<T: Encodable>(_ member: T, in key: String, on req: Request) async throws -> Bool {
        // Encode member value
        let element = try encoder.encode(member).base64EncodedString()
        // Check if element has an expiration date
        let expirationKey = "exp::\(key)::\(element)"
        let expiration: Date? = try await get(expirationKey, on: req)
        // If expiration date exist, check if it has passed
        if let expirationDate = expiration, expirationDate < .now  {
            req.logger.debug("💾 Redis item failed expiration check: '\(key)' member of type \(member.self) has now expired")
            // Delete expiration date key
            let _ = try await del([expirationKey], on: req)
            // Delete member
            let _ = try await sRem(member, from: key, on: req)
            // Return false if expiration has passed
            return false
        }
        // Return Redis check
        return try await req.redis.sismember(element, of: key.redisKey()).get()
    }

    // SREM
    public func sRem<T: Encodable>(_ member: T, from key: String, on req: Request) async throws -> Int {
        // Encode member
        let element = try encoder.encode(member).base64EncodedString()
        // Delete any expiration tied to the member
        let expiration = "exp::\(key)::\(element)"
        let _ = try await del([expiration], on: req)
        // Delete member
        let result = try await req.redis.srem([element], from: key.redisKey()).get()
        req.logger.debug("💾 Redis item deleted: '\(key)' member of type \(member.self) was deleted")
        return result
    }
}
