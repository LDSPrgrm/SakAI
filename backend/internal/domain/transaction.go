package domain

import (
	"context"
	"database/sql"
)

// TransactionManager defines an interface for handling database transactions.
// This allows repositories to share a common transaction object when needed.
type TransactionManager interface {
	WithTransaction(ctx context.Context, fn func(ctx context.Context) error) error
}

// TransactionContext is a helper to retrieve the transaction from the context.
// In a real application, you might use a custom context key.
type TransactionContext interface {
	GetTx(ctx context.Context) *sql.Tx
}
