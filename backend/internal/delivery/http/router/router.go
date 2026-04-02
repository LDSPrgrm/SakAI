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
	Auth   *handler.AuthHandler
	Driver *handler.DriverHandler
	Ride   *handler.RideHandler
	Admin  *handler.AdminHandler
	Fare   *handler.FareHandler
	Audit  *handler.AuditHandler
	WS     *ws.Handler
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
			// Dashboard: All admin roles (content filtered by UC)
			admin.GET("/dashboard", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleFinance, domain.RoleSupport), d.Admin.GetDashboard)

			// Admin Management: Super Admin only
			admin.GET("/users", middleware.RequireRole(domain.RoleSuperadmin), d.Admin.ListAdmins)
			admin.POST("/users", middleware.RequireRole(domain.RoleSuperadmin), d.Admin.CreateAdmin)
			admin.PUT("/users/:id", middleware.RequireRole(domain.RoleSuperadmin), d.Admin.UpdateAdminStatus)

			// Fare & Surge: Super Admin and Finance (view for Finance)
			admin.GET("/fares", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleFinance), d.Fare.GetConfig)
			admin.PUT("/fares", middleware.RequireRole(domain.RoleSuperadmin), d.Fare.UpdateFares)
			admin.PUT("/surge", middleware.RequireRole(domain.RoleSuperadmin), d.Fare.UpdateSurge)
			admin.POST("/fares/simulate", middleware.RequireRole(domain.RoleSuperadmin), d.Fare.SimulateFare)

			// Incidents: Super Admin, Operations, Support (read only for Support)
			admin.GET("/incidents", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations, domain.RoleSupport), d.Admin.ListIncidents)
			admin.PUT("/incidents/:id/resolve", middleware.RequireRole(domain.RoleSuperadmin, domain.RoleOperations), d.Admin.ResolveIncident)

			// Audit Log: Super Admin only
			admin.GET("/audit", middleware.RequireRole(domain.RoleSuperadmin), d.Audit.List)
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
