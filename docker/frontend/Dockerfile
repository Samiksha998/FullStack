# ---------- Step 1: Build the React app ----------
FROM node:14.17.0 AS build

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Copy source code
COPY . .

# Build the React app
RUN npm run build

# ---------- Step 2: Serve using 'serve' ----------
FROM node:14.17.0

# Install a simple static server
RUN npm install -g serve

WORKDIR /app

# Copy build output from previous stage
COPY --from=build /app/build ./build

# Set environment variable (optional if passed via docker-compose)
ENV REACT_APP_SERVER_URL=http://backend:8080

# Expose React app port
EXPOSE 3000

# Serve the built app
CMD ["serve", "-s", "build", "-l", "3000"]
