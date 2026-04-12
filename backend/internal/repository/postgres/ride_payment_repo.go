package postgres

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

// ridePaymentRepo implements domain.RidePaymentRepository using PostgreSQL.
type ridePaymentRepo struct{ db *pgxpool.Pool }

// NewRidePaymentRepo creates a new Postgres-backed RidePaymentRepository.
func NewRidePaymentRepo(db *pgxpool.Pool) domain.RidePaymentRepository {
	return &ridePaymentRepo{db: db}
}

func (r *ridePaymentRepo) Create(ctx context.Context, payment *domain.Payment) error {
	const q = `
		INSERT INTO ride_payments (
			id, ride_id, amount, currency, method, status,
			gateway_transaction_id, gateway_response, processed_at, failure_reason, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`
	_, err := r.db.Exec(ctx, q,
		payment.ID, payment.RideID, payment.Amount, payment.Currency, payment.Method,
		payment.Status, payment.GatewayTransactionID, payment.GatewayResponse,
		payment.ProcessedAt, payment.FailureReason, payment.CreatedAt,
	)
	return err
}

func (r *ridePaymentRepo) GetByRideID(ctx context.Context, rideID uuid.UUID) (*domain.Payment, error) {
	const q = `
		SELECT id, ride_id, amount, currency, method, status,
		       gateway_transaction_id, gateway_response, processed_at,
		       failure_reason, created_at
		FROM ride_payments
		WHERE ride_id = $1`
	return r.scanPayment(r.db.QueryRow(ctx, q, rideID))
}

func (r *ridePaymentRepo) UpdateStatus(ctx context.Context, id uuid.UUID, status domain.PaymentStatus, gatewayTxnID *string, processedAt time.Time, failureReason *string) error {
	const q = `
		UPDATE ride_payments
		SET status = $1,
		    gateway_transaction_id = $2,
		    processed_at = $3,
		    failure_reason = $4
		WHERE id = $5`
	_, err := r.db.Exec(ctx, q, status, gatewayTxnID, processedAt, failureReason, id)
	return err
}

func (r *ridePaymentRepo) scanPayment(row pgx.Row) (*domain.Payment, error) {
	payment := &domain.Payment{}
	err := row.Scan(
		&payment.ID, &payment.RideID, &payment.Amount, &payment.Currency, &payment.Method,
		&payment.Status, &payment.GatewayTransactionID, &payment.GatewayResponse,
		&payment.ProcessedAt, &payment.FailureReason, &payment.CreatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	return payment, err
}
