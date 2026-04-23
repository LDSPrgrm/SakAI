package handler

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/sakai/backend/internal/domain"
)

type ReportHandler struct {
	uc domain.ReportUseCase
}

func NewReportHandler(uc domain.ReportUseCase) *ReportHandler {
	return &ReportHandler{uc: uc}
}

func (h *ReportHandler) ListReports(c *gin.Context) {
	reports, err := h.uc.ListReports(c.Request.Context())
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, reports)
}

func (h *ReportHandler) GetChartData(c *gin.Context) {
	reportType := c.Param("type")
	from, to := parseDateRange(c)
	data, err := h.uc.GetChartData(c.Request.Context(), reportType, from, to)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, data)
}

func (h *ReportHandler) ExportReport(c *gin.Context) {
	reportType := c.Param("type")
	from, to := parseDateRange(c)
	csvData, err := h.uc.ExportReport(c.Request.Context(), reportType, from, to)
	if err != nil {
		respondError(c, err)
		return
	}
	c.Header("Content-Disposition", "attachment; filename="+reportType+".csv")
	c.Data(http.StatusOK, "text/csv", csvData)
}

// parseDateRange reads the optional ?from=YYYY-MM-DD&to=YYYY-MM-DD pair used by
// the admin reports UI. Invalid dates are silently ignored so the repo falls
// back to its 30-day default.
func parseDateRange(c *gin.Context) (*time.Time, *time.Time) {
	var from, to *time.Time
	if raw := c.Query("from"); raw != "" {
		if t, err := time.Parse("2006-01-02", raw); err == nil {
			from = &t
		}
	}
	if raw := c.Query("to"); raw != "" {
		if t, err := time.Parse("2006-01-02", raw); err == nil {
			to = &t
		}
	}
	return from, to
}
