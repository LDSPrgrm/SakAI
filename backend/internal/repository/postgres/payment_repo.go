package postgres

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

// In-memory payouts store. Replace with a real driver_payouts table migration
// later. Guarded by a mutex so concurrent admin requests don't race.
var (
	payoutsOnce  sync.Once
	payoutsMu    sync.Mutex
	payoutsStore []*domain.DriverPayout
)

func initPayouts() {
	payoutsOnce.Do(func() {
		payoutsStore = []*domain.DriverPayout{
			{ID: uuid.New(), Batch: "2026-W14", DriverCount: 24, TotalAmount: 18400.00, Period: "Apr 1–7 2026", Status: "pending"},
			{ID: uuid.New(), Batch: "2026-W13", DriverCount: 20, TotalAmount: 15200.50, Period: "Mar 25–31 2026", Status: "approved"},
		}
	})
}

type paymentRepo struct{ db *pgxpool.Pool }

func NewPaymentRepo(db *pgxpool.Pool) domain.PaymentRepository {
	return &paymentRepo{db: db}
}

func (r *paymentRepo) ListTransactions(_ context.Context, _, _ int) ([]*domain.Transaction, int, error) {
	// Stub: transactions table pending billing schema
	stubs := []*domain.Transaction{
		{
			ID: uuid.New(), RiderName: "Juan dela Cruz", DriverName: "Pedro Santos",
			Amount: 85.00, PaymentMethod: "gcash", Status: "settled", Commission: 8.50,
			CreatedAt: time.Now().Add(-2 * time.Hour),
		},
		{
			ID: uuid.New(), RiderName: "Maria Reyes", DriverName: "Jose Aquino",
			Amount: 120.50, PaymentMethod: "cash", Status: "settled", Commission: 12.05,
			CreatedAt: time.Now().Add(-4 * time.Hour),
		},
		{
			ID: uuid.New(), RiderName: "Ana Gonzales", DriverName: "Carlo Mendoza",
			Amount: 65.00, PaymentMethod: "paymaya", Status: "pending", Commission: 6.50,
			CreatedAt: time.Now().Add(-1 * time.Hour),
		},
	}
	return stubs, len(stubs), nil
}

func (r *paymentRepo) GetPaymentSummary(_ context.Context) (*domain.PaymentSummary, error) {
	// Stub: billing schema pending
	return &domain.PaymentSummary{
		TotalRevenue:       48250.75,
		Payouts:            38600.60,
		Commission:         4825.07,
		PendingSettlements: 2500.00,
	}, nil
}

func (r *paymentRepo) ListPayouts(_ context.Context) ([]*domain.DriverPayout, error) {
	initPayouts()
	payoutsMu.Lock()
	defer payoutsMu.Unlock()
	out := make([]*domain.DriverPayout, len(payoutsStore))
	for i, p := range payoutsStore {
		cp := *p
		out[i] = &cp
	}
	return out, nil
}

func (r *paymentRepo) ApprovePayout(_ context.Context, id uuid.UUID) error {
	initPayouts()
	payoutsMu.Lock()
	defer payoutsMu.Unlock()
	for _, p := range payoutsStore {
		if p.ID == id {
			p.Status = "approved"
			return nil
		}
	}
	return fmt.Errorf("payout %s not found", id)
}

func (r *paymentRepo) GetGatewayConfigs(ctx context.Context) ([]*domain.PaymentGatewayConfig, error) {
	// Delegate to existing adminRepo query
	const q = `SELECT id, provider, config_fields, is_active, updated_at, updated_by FROM payment_gateway_configs`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var configs []*domain.PaymentGatewayConfig
	for rows.Next() {
		c := &domain.PaymentGatewayConfig{}
		if err := rows.Scan(&c.ID, &c.Provider, &c.ConfigFields, &c.IsActive, &c.UpdatedAt, &c.UpdatedBy); err != nil {
			return nil, err
		}
		configs = append(configs, c)
	}
	if configs == nil {
		// Return stubs if table is empty
		configs = []*domain.PaymentGatewayConfig{
			{ID: uuid.New(), Provider: "gcash", IsActive: true, UpdatedAt: time.Now()},
			{ID: uuid.New(), Provider: "paymaya", IsActive: true, UpdatedAt: time.Now()},
			{ID: uuid.New(), Provider: "card", IsActive: false, UpdatedAt: time.Now()},
		}
	}
	return configs, nil
}

func (r *paymentRepo) UpdateGatewayConfig(ctx context.Context, c *domain.PaymentGatewayConfig) error {
	const q = `
		INSERT INTO payment_gateway_configs (provider, config_fields, is_active, updated_at, updated_by)
		VALUES ($1, $2, $3, NOW(), $4)
		ON CONFLICT (provider) DO UPDATE SET
			config_fields = EXCLUDED.config_fields,
			is_active = EXCLUDED.is_active,
			updated_at = NOW(),
			updated_by = EXCLUDED.updated_by`
	_, err := r.db.Exec(ctx, q, c.Provider, c.ConfigFields, c.IsActive, c.UpdatedBy)
	return err
}

func (r *paymentRepo) GetCommissionSettings(ctx context.Context) ([]*domain.CommissionSettings, error) {
	const q = `SELECT id, vehicle_type, rate_percent, min_commission, updated_at, updated_by FROM commission_settings`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var settings []*domain.CommissionSettings
	for rows.Next() {
		s := &domain.CommissionSettings{}
		if err := rows.Scan(&s.ID, &s.VehicleType, &s.RatePercent, &s.MinCommission, &s.UpdatedAt, &s.UpdatedBy); err != nil {
			return nil, err
		}
		settings = append(settings, s)
	}
	if settings == nil {
		settings = []*domain.CommissionSettings{
			{ID: uuid.New(), VehicleType: "motorcycle", RatePercent: 10.0, MinCommission: 5.0, UpdatedAt: time.Now()},
			{ID: uuid.New(), VehicleType: "tricycle", RatePercent: 10.0, MinCommission: 5.0, UpdatedAt: time.Now()},
			{ID: uuid.New(), VehicleType: "car", RatePercent: 12.0, MinCommission: 8.0, UpdatedAt: time.Now()},
		}
	}
	return settings, nil
}

func (r *paymentRepo) UpdateCommissionSettings(ctx context.Context, s *domain.CommissionSettings) error {
	const q = `
		INSERT INTO commission_settings (vehicle_type, rate_percent, min_commission, updated_at, updated_by)
		VALUES ($1, $2, $3, NOW(), $4)
		ON CONFLICT (vehicle_type) DO UPDATE SET
			rate_percent = EXCLUDED.rate_percent,
			min_commission = EXCLUDED.min_commission,
			updated_at = NOW(),
			updated_by = EXCLUDED.updated_by`
	_, err := r.db.Exec(ctx, q, s.VehicleType, s.RatePercent, s.MinCommission, s.UpdatedBy)
	return err
}
