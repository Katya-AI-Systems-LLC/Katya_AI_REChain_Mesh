.PHONY: build clean test install

# Build targets
build:
	@echo "Building meshctl..."
	@go build -o bin/meshctl ./cmd/meshctl
	@echo "Building mesh-broker..."
	@go build -o bin/mesh-broker ./cmd/mesh-broker
	@echo "Build complete!"

clean:
	@rm -rf bin/
	@echo "Cleaned binaries"

install:
	@go install ./cmd/meshctl
	@go install ./cmd/mesh-broker
	@echo "Installed to GOPATH/bin"

test:
	@go test ./...

fmt:
	@go fmt ./...

vet:
	@go vet ./...

mod:
	@go mod download
	@go mod tidy

.DEFAULT_GOAL := build

