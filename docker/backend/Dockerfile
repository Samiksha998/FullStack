# Stage 1: Build the Go binary
FROM golang:1.19 AS build

WORKDIR /app

# Install dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source code and build the app
COPY . .
RUN go build -o server main.go

# Stage 2: Runtime container
FROM golang:1.19

WORKDIR /app

# Copy built Go binary and wait script
COPY --from=build /app/server .
COPY wait-for.sh .

# ✅ Copy pg_isready from official Postgres image
COPY --from=postgres:14 /usr/bin/pg_isready /usr/bin/

RUN chmod +x wait-for.sh

# Expose backend port
EXPOSE 8080

# Default env vars (can be overridden by docker-compose)
ENV DB_HOST=localhost \
    DB_USER=postgres \
    DB_PASSWORD=admin123 \
    DB_NAME=employees \
    DB_PORT=5432 \
    ALLOWED_ORIGINS=http://localhost:3000

# Start script: wait for DB, then start backend
CMD ["./wait-for.sh", "postgres", "./server"]
