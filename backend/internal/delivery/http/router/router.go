// Package router assembles the Gin engine with all routes and middleware.
package router

import (
	"net/http"

	"github.com/gin-gonic/gin"

	handler "github.com/sakai/backend/internal/delivery/http"
	"github.com/sakai/backend/internal/delivery/http/middleware"
	"github.com/sakai/backend/internal/delivery/ws"
	"github.com/sakai/backend/internal/domain"
)

// Deps is the set of pre-constructed handlers injected into the router.
type Deps struct {
	Auth    *handler.AuthHandler
	Driver  *handler.DriverHandler
	Ride    *handler.RideHandler
	Admin   *handler.AdminHandler
	Fare    *handler.FareHandler
	Audit   *handler.AuditHandler
	Role    *handler.RoleHandler
	Payment *handler.PaymentHandler
	Safety  *handler.SafetyHandler
	System  *handler.SystemHandler
	Report  *handler.ReportHandler
	Metrics *handler.MetricsHandler
	WS      *ws.Handler
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

	api := r.Group("/api")

	// ── Health check ──────────────────────────────────────────────────────────
	api.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

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
		authed.GET("/rides/active", d.Ride.GetActive)

		// Driver-only routes
		driverOnly := authed.Group("/driver")
		driverOnly.Use(middleware.RequireRole(domain.RoleDriver))
		{
			driverOnly.PUT("/status", d.Driver.SetStatus)
			driverOnly.PUT("/location", d.Driver.UpdateLocation)
			driverOnly.GET("/rides/incoming", d.Driver.GetIncomingRide)
		}

		// ─── Super Admin / Admin Routes ──────────────────────────────────────────
		admin := authed.Group("/admin")
		{
			// Dashboard
			admin.GET("/dashboard", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleFinance, domain.RoleSupport), d.Admin.GetDashboard)

			// Auth
			admin.PUT("/auth/password", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleFinance, domain.RoleSupport), d.Auth.ChangePassword)

			// Metrics
			admin.GET("/metrics/riders", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleFinance, domain.RoleSupport), d.Metrics.GetRiders)
			admin.GET("/metrics/drivers", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleFinance, domain.RoleSupport), d.Metrics.GetDrivers)
			admin.GET("/metrics/rides", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleFinance, domain.RoleSupport), d.Metrics.GetRides)
			admin.GET("/metrics/revenue", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance), d.Metrics.GetRevenue)
			admin.GET("/metrics/wait-time", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleSupport), d.Metrics.GetWaitTime)

			// Admin Management
			admin.GET("/users", middleware.RequireRole(domain.RoleSuperadmin), d.Admin.ListAdmins)
			admin.POST("/users", middleware.RequireRole(domain.RoleSuperadmin), d.Admin.CreateAdmin)
			admin.PUT("/users/:id", middleware.RequireRole(domain.RoleSuperadmin), d.Admin.UpdateAdminStatus)
			admin.DELETE("/users/:id", middleware.RequireRole(domain.RoleSuperadmin), d.Admin.DeactivateAdmin)
			admin.GET("/users/:id/activity", middleware.RequireRole(domain.RoleSuperadmin), d.Admin.GetAdminActivity)

			// Role Management
			admin.GET("/roles", middleware.RequireRole(domain.RoleSuperadmin), d.Role.ListRoles)
			admin.POST("/roles", middleware.RequireRole(domain.RoleSuperadmin), d.Role.CreateRole)
			admin.GET("/roles/:id", middleware.RequireRole(domain.RoleSuperadmin), d.Role.GetRole)
			admin.PUT("/roles/:id", middleware.RequireRole(domain.RoleSuperadmin), d.Role.UpdateRole)
			admin.DELETE("/roles/:id", middleware.RequireRole(domain.RoleSuperadmin), d.Role.DeleteRole)
			admin.GET("/roles/:id/permissions", middleware.RequireRole(domain.RoleSuperadmin), d.Role.GetRolePermissions)
			admin.GET("/roles/:id/admins", middleware.RequireRole(domain.RoleSuperadmin), d.Role.GetRoleAdmins)

			// Ride & User browsing
			admin.GET("/rides", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleFinance, domain.RoleSupport), d.Admin.ListRides)
			admin.GET("/passengers", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleSupport), d.Admin.ListPassengers)
			admin.GET("/drivers", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleSupport), d.Admin.ListDrivers)

			// Fare & Surge
			admin.GET("/fares", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance), d.Fare.GetConfig)
			admin.PUT("/fares", middleware.RequireRole(domain.RoleSuperadmin), d.Fare.UpdateFares)
			admin.GET("/fares/surge", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance), d.Fare.GetSurgeConfig)
			admin.PUT("/surge", middleware.RequireRole(domain.RoleSuperadmin), d.Fare.UpdateSurge)
			admin.POST("/fares/simulate", middleware.RequireRole(domain.RoleSuperadmin), d.Fare.SimulateFare)

			// Payments
			admin.GET("/payments/transactions", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance, domain.RoleOperations), d.Payment.ListTransactions)
			admin.GET("/payments/summary", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance), d.Payment.GetSummary)
			admin.GET("/payments/payouts", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance), d.Payment.ListPayouts)
			admin.PUT("/payments/payouts/:id/approve", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance), d.Payment.ApprovePayout)
			admin.POST("/payments/payouts/approve", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance), d.Payment.BatchApprovePayouts)
			admin.GET("/payments/config", middleware.RequireRole(domain.RoleSuperadmin), d.Payment.GetGatewayConfigs)
			admin.PUT("/payments/config/:provider", middleware.RequireRole(domain.RoleSuperadmin), d.Payment.UpdateGatewayConfig)
			admin.GET("/payments/commission", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance), d.Payment.GetCommissionSettings)
			admin.PUT("/payments/commission", middleware.RequireRole(domain.RoleSuperadmin), d.Payment.UpdateCommissionSettings)

			// Safety & Incidents
			admin.GET("/incidents", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleSupport), d.Admin.ListIncidents)
			admin.PUT("/incidents/:id/resolve", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations), d.Admin.ResolveIncident)
			admin.GET("/safety/incidents", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleSupport), d.Admin.ListIncidents)
			admin.PUT("/safety/incidents/:id", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations), d.Admin.ResolveIncident)
			admin.GET("/safety/kyc", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations), d.Safety.ListKyc)
			admin.PUT("/safety/kyc/:id", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations), d.Safety.UpdateKyc)
			admin.POST("/safety/kyc/batch", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations), d.Safety.BatchKyc)
			admin.GET("/safety/compliance", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations), d.Safety.GetCompliance)

			// System
			admin.GET("/system/services", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations), d.System.ListServices)
			admin.GET("/system/feature-flags", middleware.RequireRole(domain.RoleSuperadmin), d.System.ListFeatureFlags)
			admin.PUT("/system/feature-flags/:key", middleware.RequireRole(domain.RoleSuperadmin), d.System.UpdateFeatureFlag)
			admin.GET("/system/integrations", middleware.RequireRole(domain.RoleSuperadmin), d.System.ListIntegrations)
			admin.PUT("/system/integrations/:service", middleware.RequireRole(domain.RoleSuperadmin), d.System.UpdateIntegration)
			admin.POST("/system/integrations/:service/test", middleware.RequireRole(domain.RoleSuperadmin), d.System.TestIntegration)
			admin.GET("/system/notification-templates", middleware.RequireRole(domain.RoleSuperadmin), d.System.ListNotificationTemplates)
			admin.PUT("/system/notification-templates/:event", middleware.RequireRole(domain.RoleSuperadmin), d.System.UpdateNotificationTemplate)

			// Reports
			admin.GET("/reports/list", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance, domain.RoleOperations, domain.RoleSupport), d.Report.ListReports)
			admin.GET("/reports/chart/:type", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance, domain.RoleOperations, domain.RoleSupport), d.Report.GetChartData)
			admin.POST("/reports/export/:type", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance, domain.RoleOperations), d.Report.ExportReport)

			// Audit Log
			admin.GET("/audit", middleware.RequireRole(domain.RoleSuperadmin), d.Audit.List)
			admin.GET("/audit/export", middleware.RequireRole(domain.RoleSuperadmin), d.Audit.Export)
		}


		// Ride routes — mixed roles (enforced per handler/use-case)
		rides := authed.Group("/rides")
		{
			rides.POST("", middleware.RequireRole(domain.RolePassenger), d.Ride.RequestRide)
			rides.GET("/:rideId", d.Ride.GetByID)
			rides.POST("/:rideId/cancel", d.Ride.Cancel)

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
		}

		// WebSocket — any authenticated user
		authed.GET("/ws", d.WS.ServeWS)
	}

	return r
}
