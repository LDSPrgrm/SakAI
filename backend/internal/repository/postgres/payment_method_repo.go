package postgres

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

// paymentMethodRepo implements domain.PaymentMethodRepository using PostgreSQL.
type paymentMethodRepo struct{ db *pgxpool.Pool }

// NewPaymentMethodRepo creates a new Postgres-backed PaymentMethodRepository.
func NewPaymentMethodRepo(db *pgxpool.Pool) domain.PaymentMethodRepository {
	return &paymentMethodRepo{db: db}
}

func (r *paymentMethodRepo) Create(ctx context.Context, pm *domain.SavedPaymentMethod) error {
	const q = `
		INSERT INTO saved_payment_methods (
			id, user_id, type, is_default, card_details, ewallet_details, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7)`

	var cardJSON, ewalletJSON []byte
	var err error
	if pm.Card != nil {
		cardJSON, err = json.Marshal(pm.Card)
		if err != nil {
			return err
		}
	}
	if pm.EWallet != nil {
		ewalletJSON, err = json.Marshal(pm.EWallet)
		if err != nil {
			return err
		}
	}

	_, err = r.db.Exec(ctx, q,
		pm.ID, pm.UserID, pm.Type, pm.IsDefault,
		cardJSON, ewalletJSON, pm.CreatedAt,
	)
	return err
}

func (r *paymentMethodRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.SavedPaymentMethod, error) {
	const q = `
		SELECT id, user_id, type, is_default, card_details, ewallet_details, created_at
		FROM saved_payment_methods
		WHERE id = $1`

	return r.scanPaymentMethod(r.db.QueryRow(ctx, q, id))
}

func (r *paymentMethodRepo) ListByUserID(ctx context.Context, userID uuid.UUID) ([]*domain.SavedPaymentMethod, error) {
	const q = `
		SELECT id, user_id, type, is_default, card_details, ewallet_details, created_at
		FROM saved_payment_methods
		WHERE user_id = $1
		ORDER BY is_default DESC, created_at DESC`

	rows, err := r.db.Query(ctx, q, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var methods []*domain.SavedPaymentMethod
	for rows.Next() {
		pm, err := r.scanPaymentMethod(rows)
		if err != nil {
			return nil, err
		}
		methods = append(methods, pm)
	}
	return methods, rows.Err()
}

func (r *paymentMethodRepo) Delete(ctx context.Context, id uuid.UUID) error {
	const q = `DELETE FROM saved_payment_methods WHERE id = $1`
	_, err := r.db.Exec(ctx, q, id)
	return err
}

func (r *paymentMethodRepo) SetDefault(ctx context.Context, id uuid.UUID) error {
	// First, get the user_id for this payment method
	pm, err := r.GetByID(ctx, id)
	if err != nil {
		return err
	}

	// Clear all defaults for this user
	if err := r.ClearDefaults(ctx, pm.UserID); err != nil {
		return err
	}

	// Set this one as default
	const q = `UPDATE saved_payment_methods SET is_default = true WHERE id = $1`
	_, err = r.db.Exec(ctx, q, id)
	return err
}

func (r *paymentMethodRepo) ClearDefaults(ctx context.Context, userID uuid.UUID) error {
	const q = `UPDATE saved_payment_methods SET is_default = false WHERE user_id = $1`
	_, err := r.db.Exec(ctx, q, userID)
	return err
}

func (r *paymentMethodRepo) ExistsByUser(ctx context.Context, id uuid.UUID, userID uuid.UUID) (bool, error) {
	const q = `SELECT EXISTS(SELECT 1 FROM saved_payment_methods WHERE id = $1 AND user_id = $2)`
	var exists bool
	err := r.db.QueryRow(ctx, q, id, userID).Scan(&exists)
	return exists, err
}

func (r *paymentMethodRepo) scanPaymentMethod(row pgx.Row) (*domain.SavedPaymentMethod, error) {
	pm := &domain.SavedPaymentMethod{}
	var cardJSON, ewalletJSON []byte

	err := row.Scan(
		&pm.ID, &pm.UserID, &pm.Type, &pm.IsDefault,
		&cardJSON, &ewalletJSON, &pm.CreatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	if err != nil {
		return nil, err
	}

	if len(cardJSON) > 0 {
		pm.Card = &domain.SavedCardDetails{}
		if err := json.Unmarshal(cardJSON, pm.Card); err != nil {
			return nil, err
		}
	}
	if len(ewalletJSON) > 0 {
		pm.EWallet = &domain.SavedEWalletDetails{}
		if err := json.Unmarshal(ewalletJSON, pm.EWallet); err != nil {
			return nil, err
		}
	}

	return pm, nil
}
