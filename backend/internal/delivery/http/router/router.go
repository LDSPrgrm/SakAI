// Package router assembles the Gin engine with all routes and middleware.
package router

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	handler "github.com/sakai/backend/internal/delivery/http"
	"github.com/sakai/backend/internal/delivery/http/middleware"
	"github.com/sakai/backend/internal/delivery/ws"
	"github.com/sakai/backend/internal/domain"
)

// Deps is the set of pre-constructed handlers injected into the router.
type Deps struct {
	Auth           *handler.AuthHandler
	Driver         *handler.DriverHandler
	Ride           *handler.RideHandler
	Admin          *handler.AdminHandler
	Fare           *handler.FareHandler
	Audit          *handler.AuditHandler
	Role           *handler.RoleHandler
	Payment        *handler.PaymentHandler
	Safety         *handler.SafetyHandler
	System         *handler.SystemHandler
	Report         *handler.ReportHandler
	Metrics        *handler.MetricsHandler
	Document       *handler.DocumentHandler
	Rating         *handler.RatingHandler
	PayProcess     *handler.RidePaymentHandler
	Tip            *handler.TipHandler
	PaymentMethod  *handler.PaymentMethodHandler
	ServiceArea    *handler.ServiceAreaHandler
	LGUPartnership *handler.LGUPartnershipHandler
	Alert          *handler.AlertHandler
	Promotion      *handler.PromotionHandler
	SavedPlace     *handler.SavedPlaceHandler
	WS             *ws.Handler
	// PerfSampler receives per-request timing samples for the System Health
	// dashboard. May be nil in tests — the middleware no-ops in that case.
	PerfSampler middleware.PerfSampler
	// FilesRoot is the absolute directory that backs authenticated
	// GET /files/* responses. Empty disables the route.
	FilesRoot string
	// AuthUC + RoleUC back the dynamic permission middleware. Both must be
	// supplied for admin routes to function.
	AuthUC domain.AuthUseCase
	RoleUC domain.RoleUseCase
}

// New builds and returns the configured Gin engine.
func New(jwtSecret string, d Deps) *gin.Engine {
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(gin.Logger())

	// Apply Global Security Middlewares
	r.Use(middleware.CORS())
	r.Use(middleware.MaxBodySize(1 << 20)) // 1 MiB body size limit
	r.Use(middleware.SecurityHeaders())
	r.Use(middleware.Perf(d.PerfSampler))

	// Permission guard factory — superadmin bypass, 30s LRU cache.
	requirePerm := middleware.NewPermissionGuard(d.AuthUC, d.RoleUC)

	api := r.Group("/api")

	// ── Health check ──────────────────────────────────────────────────────────
	api.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "ok",
			"timestamp": time.Now().Format(time.RFC3339),
			"version":   "1.0.0", // TODO: Get from config/build info
		})
	})

	// ── Public: service area coverage (mobile discovery) ─────────────────────
	if d.ServiceArea != nil {
		api.GET("/service-area", d.ServiceArea.ListPublic)
	}

	// ── Public auth routes ────────────────────────────────────────────────────
	auth := api.Group("/auth")
	{
		// Rate-limited: brute-force and credential-stuffing protection (10 rpm / IP).
		auth.POST("/register", middleware.RateLimit, d.Auth.Register)
		auth.POST("/login", middleware.RateLimit, d.Auth.Login)
		auth.POST("/refresh", d.Auth.Refresh)
		auth.POST("/logout", d.Auth.Logout)
	}

	// ── Authenticated routes ──────────────────────────────────────────────────
	authed := api.Group("/")
	authed.Use(middleware.Auth(jwtSecret))
	{
		// Session recovery
		authed.GET("/users/me", d.Auth.GetMe)
		authed.DELETE("/users/me", d.Auth.DeleteMe)
		authed.GET("/rides/active", d.Ride.GetActive)

		// Driver-only routes
		driverOnly := authed.Group("/driver")
		driverOnly.Use(middleware.RequireRole(domain.RoleDriver))
		{
			driverOnly.PUT("/status", d.Driver.SetStatus)
			driverOnly.GET("/status", d.Driver.GetStatus)
			driverOnly.PUT("/location", d.Driver.UpdateLocation)
			driverOnly.GET("/rides/incoming", d.Driver.GetIncomingRide)
			driverOnly.GET("/rides", d.Ride.ListDriverRides)
			driverOnly.GET("/earnings", d.Driver.GetEarnings)
		}

		// ─── Super Admin / Admin Routes ──────────────────────────────────────────
		// All admin routes use dynamic permission gating via requirePerm("key", "read"|"write").
		// Superadmin bypasses inside the middleware. Permission keys map to the
		// role_permissions DB table (see TEST_ACCOUNTS.md for the canonical matrix).
		admin := authed.Group("/admin")
		{
			// Self-scoped: any authenticated user may read their own role's
			// permissions to drive sidebar/UI gating. No guard.
			admin.GET("/me/permissions", d.Role.GetMyPermissions)

			// Self-scoped password change — any authenticated admin may change
			// their own password. Gate by authentication only (no permission key).
			admin.PUT("/auth/password", d.Auth.ChangePassword)

			// Dashboard + metrics
			admin.GET("/dashboard", requirePerm("dashboard", "read"), d.Admin.GetDashboard)
			admin.GET("/metrics/riders", requirePerm("dashboard", "read"), d.Metrics.GetRiders)
			admin.GET("/metrics/drivers", requirePerm("dashboard", "read"), d.Metrics.GetDrivers)
			admin.GET("/metrics/rides", requirePerm("dashboard", "read"), d.Metrics.GetRides)
			admin.GET("/metrics/revenue", requirePerm("payments", "read"), d.Metrics.GetRevenue)
			admin.GET("/metrics/wait-time", requirePerm("dashboard", "read"), d.Metrics.GetWaitTime)
			admin.GET("/drivers/heatmap", requirePerm("dashboard", "read"), d.Metrics.GetDriverHeatmap)

			// Admin Management
			admin.GET("/users", requirePerm("admin_management", "read"), d.Admin.ListAdmins)
			admin.POST("/users", requirePerm("admin_management", "write"), d.Admin.CreateAdmin)
			admin.PUT("/users/:id", requirePerm("admin_management", "write"), d.Admin.UpdateAdminStatus)
			admin.DELETE("/users/:id", requirePerm("admin_management", "write"), d.Admin.DeactivateAdmin)
			admin.GET("/users/:id/activity", requirePerm("admin_management", "read"), d.Admin.GetAdminActivity)
			admin.PUT("/users/:id/password", requirePerm("admin_management", "write"), d.Admin.ResetUserPassword)

			// Role Management
			admin.GET("/roles", requirePerm("role_management", "read"), d.Role.ListRoles)
			admin.POST("/roles", requirePerm("role_management", "write"), d.Role.CreateRole)
			admin.GET("/roles/:id", requirePerm("role_management", "read"), d.Role.GetRole)
			admin.PUT("/roles/:id", requirePerm("role_management", "write"), d.Role.UpdateRole)
			admin.DELETE("/roles/:id", requirePerm("role_management", "write"), d.Role.DeleteRole)
			admin.GET("/roles/:id/permissions", requirePerm("role_management", "read"), d.Role.GetRolePermissions)
			admin.GET("/roles/:id/admins", requirePerm("role_management", "read"), d.Role.GetRoleAdmins)
			admin.POST("/roles/:id/duplicate", requirePerm("role_management", "write"), d.Role.DuplicateRole)

			// Ride & User browsing
			admin.GET("/rides", requirePerm("user_management", "read"), d.Admin.ListRides)
			admin.GET("/users/passengers", requirePerm("user_management", "read"), d.Admin.ListPassengers)
			admin.GET("/users/drivers", requirePerm("user_management", "read"), d.Admin.ListDrivers)

			// Fare & Surge
			admin.GET("/fares", requirePerm("fare_config", "read"), d.Fare.GetConfig)
			admin.PUT("/fares", requirePerm("fare_config", "write"), d.Fare.UpdateFares)
			admin.GET("/fares/surge", requirePerm("fare_config", "read"), d.Fare.GetSurgeConfig)
			admin.PUT("/surge", requirePerm("fare_config", "write"), d.Fare.UpdateSurge)
			admin.POST("/fares/simulate", requirePerm("fare_config", "read"), d.Fare.SimulateFare)

			// Payments
			admin.GET("/payments/transactions", requirePerm("payments", "read"), d.Payment.ListTransactions)
			admin.GET("/payments/summary", requirePerm("payments", "read"), d.Payment.GetSummary)
			admin.GET("/payments/payouts", requirePerm("payouts", "read"), d.Payment.ListPayouts)
			admin.PUT("/payments/payouts/:id/approve", requirePerm("payouts", "write"), d.Payment.ApprovePayout)
			admin.POST("/payments/payouts/approve", requirePerm("payouts", "write"), d.Payment.BatchApprovePayouts)
			admin.GET("/payments/config", requirePerm("payments", "read"), d.Payment.GetGatewayConfigs)
			admin.PUT("/payments/config/:provider", requirePerm("payments", "write"), d.Payment.UpdateGatewayConfig)
			admin.GET("/payments/commission-config", requirePerm("payments", "read"), d.Payment.GetCommissionSettings)
			admin.PUT("/payments/commission-config", requirePerm("payments", "write"), d.Payment.UpdateCommissionSettings)

			// Safety & Incidents
			admin.GET("/incidents", requirePerm("safety_incidents", "read"), d.Admin.ListIncidents)
			admin.GET("/support-staff", requirePerm("safety_incidents", "read"), d.Admin.ListAssigneeCandidates)
			admin.GET("/incidents/:id", requirePerm("safety_incidents", "read"), d.Admin.GetIncident)
			admin.PUT("/incidents/:id/assign", requirePerm("safety_incidents", "write"), d.Admin.AssignIncident)
			admin.PUT("/incidents/:id/resolve", requirePerm("safety_incidents", "write"), d.Admin.ResolveIncident)
			admin.GET("/safety/incidents", requirePerm("safety_incidents", "read"), d.Admin.ListIncidents)
			admin.PUT("/safety/incidents/:id", requirePerm("safety_incidents", "write"), d.Admin.ResolveIncident)
			admin.GET("/safety/kyc", requirePerm("kyc_verification", "read"), d.Safety.ListKyc)
			admin.PUT("/safety/kyc/:id", requirePerm("kyc_verification", "write"), d.Safety.UpdateKyc)
			admin.POST("/safety/kyc/batch", requirePerm("kyc_verification", "write"), d.Safety.BatchKyc)
			admin.GET("/safety/compliance", requirePerm("ltfrb_compliance", "read"), d.Safety.GetCompliance)

			// System
			admin.GET("/system/services", requirePerm("system_health", "read"), d.System.ListServices)
			admin.GET("/system/infra-metrics", requirePerm("system_health", "read"), d.System.GetInfraMetrics)
			admin.GET("/system/feature-flags", requirePerm("system_config", "read"), d.System.ListFeatureFlags)
			admin.PUT("/system/feature-flags/:key", requirePerm("system_config", "write"), d.System.UpdateFeatureFlag)
			admin.GET("/system/integrations", requirePerm("system_config", "read"), d.System.ListIntegrations)
			admin.PUT("/system/integrations/:service", requirePerm("system_config", "write"), d.System.UpdateIntegration)
			admin.POST("/system/integrations/:service/test", requirePerm("system_config", "write"), d.System.TestIntegration)
			admin.GET("/system/notification-templates", requirePerm("system_config", "read"), d.System.ListNotificationTemplates)
			admin.PUT("/system/notification-templates/:event", requirePerm("system_config", "write"), d.System.UpdateNotificationTemplate)

			// Reports
			admin.GET("/reports/list", requirePerm("reports", "read"), d.Report.ListReports)
			admin.GET("/reports/chart/:type", requirePerm("reports", "read"), d.Report.GetChartData)
			admin.POST("/reports/export/:type", requirePerm("reports", "write"), d.Report.ExportReport)

			// Audit Log
			admin.GET("/audit", requirePerm("audit_log", "read"), d.Audit.List)
			admin.GET("/audit/export", requirePerm("audit_log", "read"), d.Audit.Export)
			admin.POST("/audit", requirePerm("audit_log", "write"), d.Audit.Create)

			// Service areas (admin view — includes inactive) + LGU partnerships
			if d.ServiceArea != nil {
				admin.GET("/service-areas", requirePerm("ltfrb_compliance", "read"), d.ServiceArea.ListAdmin)
				admin.POST("/service-areas", requirePerm("ltfrb_compliance", "write"), d.ServiceArea.Create)
				admin.PUT("/service-areas/:id", requirePerm("ltfrb_compliance", "write"), d.ServiceArea.Update)
				admin.DELETE("/service-areas/:id", requirePerm("ltfrb_compliance", "write"), d.ServiceArea.Delete)
			}
			if d.LGUPartnership != nil {
				admin.GET("/lgu-partnerships", requirePerm("ltfrb_compliance", "read"), d.LGUPartnership.List)
				admin.GET("/lgu-partnerships/:id", requirePerm("ltfrb_compliance", "read"), d.LGUPartnership.Get)
				admin.POST("/lgu-partnerships", requirePerm("ltfrb_compliance", "write"), d.LGUPartnership.Create)
				admin.PUT("/lgu-partnerships/:id", requirePerm("ltfrb_compliance", "write"), d.LGUPartnership.Update)
				admin.DELETE("/lgu-partnerships/:id", requirePerm("ltfrb_compliance", "write"), d.LGUPartnership.Delete)
			}

			// Alerts
			if d.Alert != nil {
				admin.GET("/alerts/rules", requirePerm("system_config", "read"), d.Alert.ListRules)
				admin.POST("/alerts/rules", requirePerm("system_config", "write"), d.Alert.CreateRule)
				admin.PUT("/alerts/rules/:id", requirePerm("system_config", "write"), d.Alert.UpdateRule)
				admin.DELETE("/alerts/rules/:id", requirePerm("system_config", "write"), d.Alert.DeleteRule)
				admin.GET("/alerts/events", requirePerm("system_health", "read"), d.Alert.ListEvents)
			}
		}


		// Ride routes — mixed roles (enforced per handler/use-case)
		rides := authed.Group("/rides")
		{
			rides.GET("", middleware.RequireRole(domain.RolePassenger), d.Ride.ListMyRides)
			rides.POST("", middleware.RequireRole(domain.RolePassenger), d.Ride.RequestRide)
			rides.GET("/:rideId", d.Ride.GetByID)
			rides.POST("/:rideId/cancel", d.Ride.Cancel)
			rides.POST("/:rideId/sos", d.Ride.TriggerSOS)

			// Driver lifecycle transitions
			driverRides := rides.Group("/:rideId")
			driverRides.Use(middleware.RequireRole(domain.RoleDriver))
			{
				driverRides.POST("/accept", d.Ride.Accept)
				driverRides.POST("/decline", d.Ride.Decline)
				driverRides.POST("/arrive", d.Ride.Arrive)
				driverRides.POST("/start", d.Ride.Start)
				driverRides.POST("/complete", d.Ride.Complete)
			}

			// Rating routes (passenger or driver)
			rides.POST("/:rideId/rating", d.Rating.SubmitRating)
			rides.GET("/:rideId/receipt", d.PayProcess.GetReceipt)

			// Tip route (passenger only)
			rides.POST("/:rideId/tip", middleware.RequireRole(domain.RolePassenger), d.Tip.AddTip)
		}

		// Nearby drivers (passenger only)
		authed.GET("/drivers/nearby", middleware.RequireRole(domain.RolePassenger), d.Driver.GetNearbyDrivers)
		authed.GET("/drivers/nearby/all", middleware.RequireRole(domain.RolePassenger), d.Driver.GetNearbyDriversAllTypes)

		// Saved places (passenger only)
		savedPlaces := authed.Group("/users/me/saved-places")
		savedPlaces.Use(middleware.RequireRole(domain.RolePassenger))
		{
			savedPlaces.GET("", d.SavedPlace.List)
			savedPlaces.POST("", d.SavedPlace.Create)
			savedPlaces.DELETE("/:placeId", d.SavedPlace.Delete)
		}

		// Promotions (passenger only)
		promos := authed.Group("/promotions")
		promos.Use(middleware.RequireRole(domain.RolePassenger))
		{
			promos.GET("", d.Promotion.ListActive)
			promos.POST("/validate", d.Promotion.Validate)
		}

		// Payment method routes (passenger only)
		paymentMethods := authed.Group("/users/me/payment-methods")
		paymentMethods.Use(middleware.RequireRole(domain.RolePassenger))
		{
			paymentMethods.GET("", d.PaymentMethod.ListMethods)
			paymentMethods.POST("", d.PaymentMethod.AddMethod)
			paymentMethods.DELETE("/:paymentMethodId", d.PaymentMethod.RemoveMethod)
			paymentMethods.PUT("/:paymentMethodId/default", d.PaymentMethod.SetDefault)
		}

		// Driver document routes
		driverDocs := authed.Group("/drivers")
		driverDocs.Use(middleware.RequireRole(domain.RoleDriver))
		{
			driverDocs.POST("/documents", d.Document.UploadDocument)
			driverDocs.GET("/documents", d.Document.ListDocuments)
			driverDocs.GET("/documents/:documentId", d.Document.GetDocumentStatus)
		}

		// Payment processing route
		authed.POST("/payments/process", middleware.RequireRole(domain.RolePassenger), d.PayProcess.ProcessPayment)

		// User rating lookup (any authenticated user)
		authed.GET("/users/:userId/rating", d.Rating.GetUserRating)

		// WebSocket — any authenticated user
		authed.GET("/ws", d.WS.ServeWS)

		// Authenticated static-file serving for driver KYC docs + future uploads.
		if d.FilesRoot != "" {
			files := handler.NewFilesHandler(d.FilesRoot)
			authed.GET("/files/*filepath", files.Serve)
		}
	}

	return r
}
