package middleware

import (
	"fmt"
	"regexp"

	"github.com/gin-gonic/gin"
)

// Package-level so the formatter allocates nothing per request beyond the
// replacement itself.
var tokenParamRe = regexp.MustCompile(`(token=)[^&\s]+`)

// RedactQueryToken masks any token=... query parameter value. The WS upgrade
// authenticates via ?token=<JWT>; without this, every connect logs a live
// access token.
func RedactQueryToken(path string) string {
	return tokenParamRe.ReplaceAllString(path, "$1%5BREDACTED%5D")
}

// AccessLogger is gin.Logger with token-redacting path formatting.
func AccessLogger() gin.HandlerFunc {
	return gin.LoggerWithConfig(gin.LoggerConfig{
		Formatter: func(p gin.LogFormatterParams) string {
			return fmt.Sprintf("[GIN] %s | %3d | %13v | %15s | %-7s %s\n",
				p.TimeStamp.Format("2006/01/02 - 15:04:05"),
				p.StatusCode, p.Latency, p.ClientIP, p.Method,
				RedactQueryToken(p.Path))
		},
	})
}
