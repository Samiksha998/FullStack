# Stage 1: Build the Go binary
FROM golang:1.19 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o backend main.go

# Stage 2: Run the binary
FROM debian:bullseye-slim

WORKDIR /app

# Fiber needs timezone data
RUN apt-get update && apt-get install -y tzdata && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/backend /app/backend

# Add environment variable definitions (optional for clarity/documentation)
ENV DB_HOST=localhost \
    DB_USER=admin \
    DB_PASSWORD=admin@123 \
    DB_NAME=employeedb \
    DB_PORT=5432 \
    BACKEND_PORT=8090 \
    ALLOWED_ORIGINS=a79ea9ba271c74b07a9749c94db535b9-1245505470.us-east-1.elb.amazonaws.com

EXPOSE 8090

CMD ["./backend"]
