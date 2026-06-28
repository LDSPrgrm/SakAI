# ─── Stage 1: Build ──────────────────────────────────────────────────────────
# Build context is the REPO ROOT (set in the workflow: context: .)
# so backend/ (including internal migrations) is available.
#
# --platform=$BUILDPLATFORM pins this stage to the *host* architecture, so
# Buildx never emulates it under QEMU — it runs natively no matter which
# target platform (amd64/arm64) we're building for. Go's compiler then
# cross-compiles the actual output using GOOS/GOARCH below, which is fast
# and doesn't need emulation at all.
FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS builder

# Set automatically by Buildx per --platform target (e.g. linux / arm64)
ARG TARGETOS
ARG TARGETARCH

# Install git (needed by some go modules) and ca-certificates (TLS)
RUN apk add --no-cache git ca-certificates tzdata
WORKDIR /build

# Cache dependency downloads separately from source compilation
COPY backend/go.mod backend/go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

# Copy backend source and build a statically linked binary
COPY backend/ .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
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