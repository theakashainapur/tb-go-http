# Build Stage
FROM golang:1-alpine AS builder
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git

# Handle modules
COPY go.mod go.sum* ./
RUN go mod download

# Build the application
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server main.go

# Final Stage
FROM alpine:latest
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata

# Copy binary from builder
COPY --from=builder /app/server ./server

# Create non-root user
RUN adduser -D -g '' appuser
USER appuser

EXPOSE 8080
CMD ["./server"]
