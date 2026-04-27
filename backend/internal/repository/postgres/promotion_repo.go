package postgres

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/sakai/backend/internal/domain"
)

type promotionRepo struct{ db *pgxpool.Pool }

func NewPromotionRepo(db *pgxpool.Pool) domain.PromotionRepository {
	return &promotionRepo{db: db}
}

func (r *promotionRepo) GetByCode(ctx context.Context, code string) (*domain.Promotion, error) {
	const q = `
		SELECT id, code, title, description, discount_value, discount_type,
		       max_discount, min_ride_amount, expires_at, terms, created_at
		FROM promotions WHERE code = $1`
	return r.scanPromotion(r.db.QueryRow(ctx, q, code))
}

func (r *promotionRepo) ListActive(ctx context.Context) ([]*domain.Promotion, error) {
	const q = `
		SELECT id, code, title, description, discount_value, discount_type,
		       max_discount, min_ride_amount, expires_at, terms, created_at
		FROM promotions WHERE expires_at > $1
		ORDER BY created_at DESC`
	rows, err := r.db.Query(ctx, q, time.Now())
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var promos []*domain.Promotion
	for rows.Next() {
		p, err := r.scanPromotion(rows)
		if err != nil {
			return nil, err
		}
		promos = append(promos, p)
	}
	return promos, rows.Err()
}

func (r *promotionRepo) scanPromotion(row pgx.Row) (*domain.Promotion, error) {
	p := &domain.Promotion{}
	err := row.Scan(
		&p.ID, &p.Code, &p.Title, &p.Description, &p.DiscountValue, &p.DiscountType,
		&p.MaxDiscount, &p.MinRideAmount, &p.ExpiresAt, &p.Terms, &p.CreatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	return p, err
}
