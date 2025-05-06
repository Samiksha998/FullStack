# 🛠️ Set environment variables (PostgreSQL + CORS)
export DB_HOST=localhost
export DB_USER=postgres
export DB_PASSWORD=admin123
export DB_NAME=employees
export DB_PORT=5432
export ALLOWED_ORIGINS=http://localhost:3000

# 🔄 Fetch dependencies
go get ./...

# 🚀 Start the backend server
go run main.go
