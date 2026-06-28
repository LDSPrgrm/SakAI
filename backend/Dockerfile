# ─── Stage 1: Build ──────────────────────────────────────────────────────────
# Build context is the REPO ROOT (set in the workflow: context: .)
# so backend/ (including internal migrations) is available.
FROM golang:1.26-alpine AS builder

# Install git (needed by some go modules) and ca-certificates (TLS)
RUN apk add --no-cache git ca-certificates tzdata

WORKDIR /build

# Copy all source first so go mod tidy can resolve new imports,
# then download and verify all dependencies.
COPY backend/ .
RUN go mod tidy && go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /app/server ./cmd/api

# ─── Stage 2: Runtime ─────────────────────────────────────────────────────────
FROM scratch

# Pull in timezone data and TLS roots from the builder
COPY --from=builder /usr/share/zoneinfo                  /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt   /etc/ssl/certs/
COPY --from=builder /app/server                          /server


# Non-root UID/GID — scratch images don't have useradd, so just declare the UID
USER 65532:65532

EXPOSE 8080


ENTRYPOINT ["/server"]
