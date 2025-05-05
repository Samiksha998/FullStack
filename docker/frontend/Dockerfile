# Step 1: Build the React app
FROM node:18 as build
WORKDIR /app
COPY . .
COPY .env .env
RUN npm install
RUN npm run build

# Step 2: Serve it with a lightweight web server
FROM node:18
RUN npm install -g serve
WORKDIR /app
COPY --from=build /app/build ./build
EXPOSE 3000
CMD ["serve", "-s", "build", "-l", "3000"]
