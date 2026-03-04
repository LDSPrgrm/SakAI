.PHONY: build test lint generate vet tidy

# ──────────────────────────────────────────────
# Primary targets
# ──────────────────────────────────────────────

## build: compile the API binary
build:
	go build -o bin/api ./cmd/api

## test: run all unit tests with race detector
test:
	go test -race -count=1 ./...

## test-cover: run tests and open a coverage report in the browser
test-cover:
	go test -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

## vet: run the Go vet static analyser
vet:
	go vet ./...

## lint: run golangci-lint (must be installed separately)
lint:
	golangci-lint run ./...

## generate: regenerate all mocks from domain/ports.go
generate:
	go run go.uber.org/mock/mockgen \
		-source=internal/domain/ports.go \
		-destination=internal/domain/mocks/mock_ports.go \
		-package=mocks

## tidy: ensure go.mod and go.sum are clean
tidy:
	go mod tidy

## all: tidy, vet, generate, test, build
all: tidy vet generate test build
