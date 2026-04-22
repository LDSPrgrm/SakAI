package handler

import (
	"fmt"
	"mime/multipart"
	"net/http"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sakai/backend/internal/delivery/http/dto"
	"github.com/sakai/backend/internal/domain"
	"github.com/sakai/backend/internal/infrastructure/storage"
)

const maxUploadSize = 10 << 20 // 10 MB

// DocumentHandler handles /drivers/documents routes.
type DocumentHandler struct {
	uc       domain.DocumentUseCase
	uploader storage.Uploader
}

// NewDocumentHandler builds a DocumentHandler. The caller chooses the Uploader
// implementation — LocalUploader for dev/self-hosted, S3Uploader once cloud
// storage is adopted.
func NewDocumentHandler(uc domain.DocumentUseCase, uploader storage.Uploader) *DocumentHandler {
	return &DocumentHandler{uc: uc, uploader: uploader}
}

// UploadDocument handles POST /drivers/documents (multipart/form-data).
func (h *DocumentHandler) UploadDocument(c *gin.Context) {
	driverID := c.MustGet("userID").(uuid.UUID)

	var req dto.DocumentUploadRequest
	if err := c.ShouldBind(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}

	fileHeader, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "image file is required"})
		return
	}

	if fileHeader.Size > maxUploadSize {
		c.JSON(http.StatusRequestEntityTooLarge, gin.H{
			"code":    "FILE_TOO_LARGE",
			"message": fmt.Sprintf("File size exceeds %d MB limit", maxUploadSize>>20),
		})
		return
	}

	ext := filepath.Ext(fileHeader.Filename)
	contentType := "application/octet-stream"
	switch ext {
	case ".jpg", ".jpeg":
		contentType = "image/jpeg"
	case ".png":
		contentType = "image/png"
	default:
		c.JSON(http.StatusUnprocessableEntity, gin.H{
			"code":    "INVALID_FILE_FORMAT",
			"message": "Only JPEG and PNG images are accepted",
		})
		return
	}

	src, err := fileHeader.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": "INTERNAL_SERVER_ERROR", "message": "Failed to open upload"})
		return
	}
	defer src.Close()

	docType := req.ToDomainDocumentType()
	key := fmt.Sprintf("documents/%s/%s/%s", driverID, docType, fileHeader.Filename)

	imageURL, err := h.uploader.Put(c.Request.Context(), key, src, contentType)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": "INTERNAL_SERVER_ERROR", "message": "Failed to store file"})
		return
	}

	doc, err := h.uc.UploadDocument(
		c.Request.Context(),
		driverID,
		docType,
		req.DocumentNumber,
		req.ParseExpiryDate(),
		imageURL,
	)
	if err != nil {
		respondError(c, err)
		return
	}

	respondCreated(c, dto.NewDriverDocumentResponse(doc))
}

// ListDocuments handles GET /drivers/documents.
func (h *DocumentHandler) ListDocuments(c *gin.Context) {
	driverID := c.MustGet("userID").(uuid.UUID)

	docs, err := h.uc.ListDocuments(c.Request.Context(), driverID)
	if err != nil {
		respondError(c, err)
		return
	}

	resp := dto.DriverDocumentsListResponse{
		Documents: make([]dto.DriverDocumentResponse, len(docs)),
	}
	for i, doc := range docs {
		resp.Documents[i] = dto.NewDriverDocumentResponse(doc)
	}
	respondOK(c, resp)
}

// GetDocumentStatus handles GET /drivers/documents/:documentId.
func (h *DocumentHandler) GetDocumentStatus(c *gin.Context) {
	driverID := c.MustGet("userID").(uuid.UUID)

	documentID, err := uuid.Parse(c.Param("documentId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "invalid document ID"})
		return
	}

	doc, err := h.uc.GetDocument(c.Request.Context(), driverID, documentID)
	if err != nil {
		respondError(c, err)
		return
	}

	respondOK(c, dto.NewDriverDocumentResponse(doc))
}

// openFile is a type alias for cleaner file handling.
type openFile = multipart.File
