// Package middleware provides Gin middleware for authentication, authorization,
// and rate limiting.
package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

// ipBucket tracks the state for a single IP's token bucket.
type ipBucket struct {
	tokens    float64
	lastRefil time.Time
	mu        sync.Mutex
}

// rateLimiter holds token-bucket state keyed by IP address.
type rateLimiter struct {
	mu      sync.Mutex
	buckets map[string]*ipBucket
	// rate is tokens added per second.
	rate float64
	// burst is the maximum token accumulation (== requests allowed in a burst).
	burst float64
}

// newRateLimiter creates a limiter allowing `rpm` requests per minute per IP,
// with a burst of `rpm` (i.e. the bucket starts full).
func newRateLimiter(rpm int) *rateLimiter {
	rl := &rateLimiter{
		buckets: make(map[string]*ipBucket),
		rate:    float64(rpm) / 60.0,
		burst:   float64(rpm),
	}
	// Background goroutine purges stale buckets every 5 minutes to prevent
	// unbounded memory growth from one-off IPs.
	go func() {
		ticker := time.NewTicker(5 * time.Minute)
		defer ticker.Stop()
		for range ticker.C {
			rl.mu.Lock()
			for ip, b := range rl.buckets {
				b.mu.Lock()
				if time.Since(b.lastRefil) > 10*time.Minute {
					delete(rl.buckets, ip)
				}
				b.mu.Unlock()
			}
			rl.mu.Unlock()
		}
	}()
	return rl
}

// allow returns true if the given IP has remaining quota.
func (rl *rateLimiter) allow(ip string) bool {
	rl.mu.Lock()
	b, ok := rl.buckets[ip]
	if !ok {
		b = &ipBucket{tokens: rl.burst, lastRefil: time.Now()}
		rl.buckets[ip] = b
	}
	rl.mu.Unlock()

	b.mu.Lock()
	defer b.mu.Unlock()

	now := time.Now()
	elapsed := now.Sub(b.lastRefil).Seconds()
	b.tokens = min64(b.tokens+elapsed*rl.rate, rl.burst)
	b.lastRefil = now

	if b.tokens < 1 {
		return false
	}
	b.tokens--
	return true
}

func min64(a, b float64) float64 {
	if a < b {
		return a
	}
	return b
}

// authLimiter is the shared limiter for all auth endpoints (10 rpm per IP).
// The limit is intentionally tight — legitimate users should not be logging in
// or registering more than a handful of times per minute.
var authLimiter = newRateLimiter(10)

// RateLimit is a Gin middleware that enforces a per-IP token-bucket rate limit.
// Requests that exceed the limit receive HTTP 429 Too Many Requests.
func RateLimit(c *gin.Context) {
	ip := c.ClientIP()
	if !authLimiter.allow(ip) {
		c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
			"code":    "RATE_LIMITED",
			"message": "too many requests — please wait before trying again",
		})
		return
	}
	c.Next()
}
