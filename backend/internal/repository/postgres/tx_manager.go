package postgres

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

// txKey is a custom key for context values.
type txKey struct{}

// PgTransactionManager implements domain.TransactionManager using pgxpool.
type PgTransactionManager struct{ db *pgxpool.Pool }

// NewPgTransactionManager creates a new PgTransactionManager.
func NewPgTransactionManager(db *pgxpool.Pool) *PgTransactionManager {
	return &PgTransactionManager{db: db}
}

// WithTransaction executes the function within a database transaction.
func (tm *PgTransactionManager) WithTransaction(ctx context.Context, fn func(ctx context.Context) error) error {
	tx, err := tm.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	// Inject the transaction into the context.
	// We need to use an *sql.Tx equivalent or pass the pgx.Tx directly.
	// Since we are using pgx, we inject the pgx.Tx.
	ctx = context.WithValue(ctx, txKey{}, tx)

	if err := fn(ctx); err != nil {
		return err
	}

	return tx.Commit(ctx)
}

// GetTx retrieves the transaction from the context if it exists.
func GetTx(ctx context.Context) interface{} {
	return ctx.Value(txKey{})
}
