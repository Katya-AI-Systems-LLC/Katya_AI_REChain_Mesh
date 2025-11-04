# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod ./
RUN go mod download

# Copy source
COPY . .

# Build
RUN go build -o bin/meshctl ./cmd/meshctl
RUN go build -o bin/mesh-broker ./cmd/mesh-broker

# Runtime stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

# Copy binaries
COPY --from=builder /app/bin .

# Expose port for broker
EXPOSE 8080

# Default to broker
CMD ["./mesh-broker", "--port", "8080", "--adapter", "emulated"]

