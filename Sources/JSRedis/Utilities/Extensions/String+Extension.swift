import Redis

extension String {
    func redisKey() -> RedisKey {
        return RedisKey(self)
    }
}
