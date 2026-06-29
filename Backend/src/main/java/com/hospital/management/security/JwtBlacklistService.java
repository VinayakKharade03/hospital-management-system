package com.hospital.management.security;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
public class JwtBlacklistService {

    private final RedisTemplate<String, String> redisTemplate;

    public void blacklistToken(String token, long expiryMs) {
        try {
            redisTemplate.opsForValue().set(token, "BLACKLISTED", expiryMs, TimeUnit.MILLISECONDS);
        } catch (Exception e) {
            // Redis not running, ignore for now
            System.out.println("Redis unavailable. Skipping blacklist.");
        }
    }

    public boolean isBlacklisted(String token) {
        try {
            return Boolean.TRUE.equals(redisTemplate.hasKey(token));
        } catch (Exception e) {
            // Redis not running, assume token not blacklisted
            return false;
        }
    }
}