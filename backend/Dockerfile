# ─── Stage 1: Build ──────────────────────────────────────────────────────────
# Build context is the REPO ROOT (set in the workflow: context: .)
# so both backend/ and migrations/ are available.
FROM golang:1.26-alpine AS builder

# Install git (needed by some go modules) and ca-certificates (TLS)
RUN apk add --no-cache git ca-certificates tzdata

WORKDIR /build

# Cache dependency downloads separately from source compilation
COPY backend/go.mod backend/go.sum ./
RUN go mod download

# Copy backend source and build a statically linked binary
COPY backend/ .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /app/server ./cmd/api

# ─── Stage 2: Runtime ─────────────────────────────────────────────────────────
FROM scratch

# Pull in timezone data and TLS roots from the builder
COPY --from=builder /usr/share/zoneinfo                  /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt   /etc/ssl/certs/
COPY --from=builder /app/server                          /server

# Copy SQL migration files — the server runs golang-migrate at startup.
# MIGRATIONS_DIR env var (default: /migrations) tells the server where to find them.
COPY migrations/ /migrations/

# Non-root UID/GID — scratch images don't have useradd, so just declare the UID
USER 65532:65532

EXPOSE 8080

# Override MIGRATIONS_DIR to the absolute path inside the image
ENV MIGRATIONS_DIR=/migrations

ENTRYPOINT ["/server"]
