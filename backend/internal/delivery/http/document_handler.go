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
)

const maxUploadSize = 10 << 20 // 10 MB

// DocumentHandler handles /drivers/documents routes.
type DocumentHandler struct {
	uc domain.DocumentUseCase
	// TODO: Replace with actual cloud storage uploader (S3, GCS, etc.)
	uploadURLBuilder func(driverID uuid.UUID, docType domain.DocumentType, filename string) string
}

// NewDocumentHandler creates a new DocumentHandler.
func NewDocumentHandler(uc domain.DocumentUseCase) *DocumentHandler {
	return &DocumentHandler{
		uc: uc,
		// Stub URL builder — replace with real signed URL generation.
		uploadURLBuilder: func(driverID uuid.UUID, docType domain.DocumentType, filename string) string {
			return fmt.Sprintf("https://storage.example.com/documents/%s/%s/%s", driverID, docType, filename)
		},
	}
}

// UploadDocument handles POST /drivers/documents (multipart/form-data).
func (h *DocumentHandler) UploadDocument(c *gin.Context) {
	driverID := c.MustGet("userID").(uuid.UUID)

	// Parse form fields.
	var req dto.DocumentUploadRequest
	if err := c.ShouldBind(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": err.Error()})
		return
	}

	// Parse and validate the file header.
	fileHeader, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": "VALIDATION_ERROR", "message": "image file is required"})
		return
	}

	// Validate file size.
	if fileHeader.Size > maxUploadSize {
		c.JSON(http.StatusRequestEntityTooLarge, gin.H{
			"code":    "FILE_TOO_LARGE",
			"message": fmt.Sprintf("File size exceeds %d MB limit", maxUploadSize>>20),
		})
		return
	}

	// Validate file extension.
	ext := filepath.Ext(fileHeader.Filename)
	if ext != ".jpg" && ext != ".jpeg" && ext != ".png" {
		c.JSON(http.StatusUnprocessableEntity, gin.H{
			"code":    "INVALID_FILE_FORMAT",
			"message": "Only JPEG and PNG images are accepted",
		})
		return
	}

	// TODO: Replace with actual file upload to cloud storage.
	// For now, generate a stub URL.
	imageURL := h.uploadURLBuilder(driverID, req.ToDomainDocumentType(), fileHeader.Filename)

	// Save file to local disk for now (stub implementation).
	if err := c.SaveUploadedFile(fileHeader, fmt.Sprintf("./uploads/%s", fileHeader.Filename)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": "INTERNAL_SERVER_ERROR", "message": "Failed to save file"})
		return
	}

	// Call usecase.
	doc, err := h.uc.UploadDocument(
		c.Request.Context(),
		driverID,
		req.ToDomainDocumentType(),
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
