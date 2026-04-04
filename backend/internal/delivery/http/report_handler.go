package handler

import (
	"net/http"

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
	data, err := h.uc.GetChartData(c.Request.Context(), reportType)
	if err != nil {
		respondError(c, err)
		return
	}
	respondOK(c, data)
}

func (h *ReportHandler) ExportReport(c *gin.Context) {
	reportType := c.Param("type")
	csvData, err := h.uc.ExportReport(c.Request.Context(), reportType)
	if err != nil {
		respondError(c, err)
		return
	}
	c.Header("Content-Disposition", "attachment; filename="+reportType+".csv")
	c.Data(http.StatusOK, "text/csv", csvData)
}
