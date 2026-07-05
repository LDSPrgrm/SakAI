package middleware

import (
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus"
)

func TestPerfRecordsHistogram(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(Perf(nil)) // nil sampler: histogram must still record
	r.GET("/ping", func(c *gin.Context) { c.Status(200) })

	req := httptest.NewRequest("GET", "/ping", nil)
	r.ServeHTTP(httptest.NewRecorder(), req)

	mfs, err := prometheus.DefaultGatherer.Gather()
	if err != nil {
		t.Fatal(err)
	}
	for _, mf := range mfs {
		if mf.GetName() == "sakai_http_request_duration_seconds" {
			for _, m := range mf.GetMetric() {
				if m.GetHistogram().GetSampleCount() >= 1 {
					return
				}
			}
		}
	}
	t.Fatal("sakai_http_request_duration_seconds not recorded")
}
