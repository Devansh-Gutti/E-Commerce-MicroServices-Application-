# First stage: Build stage
FROM node:16-alpine AS builder

# Set working directory for the build
WORKDIR /build

# Copy package.json, package-lock.json, and .env files for each service
COPY uc1/package.json uc1/package-lock.json uc1/.env ./uc1/
COPY uc2/package.json uc2/package-lock.json uc2/.env ./uc2/
COPY uc3/package.json uc3/package-lock.json uc3/.env ./uc3/

# Install dependencies for each service
RUN npm install --prefix uc1 \
    && npm install --prefix uc2 \
    && npm install --prefix uc3

# Copy the application code for each service
COPY uc1/ uc1/
COPY uc2/ uc2/
COPY uc3/ uc3/

# Second stage: Runtime stage
FROM node:16-alpine

# Set working directory for each service
WORKDIR /uc1
# Copy the built files and dependencies from the builder stage for uc1
COPY --from=builder /build/uc1 .

# Expose port and define command to run the application for uc1
EXPOSE 5001
CMD [ "node", "index.js" ]

# Repeat the same process for uc2 and uc3
WORKDIR /uc2
COPY --from=builder /build/uc2 .
EXPOSE 5002
CMD [ "node", "index.js" ]

WORKDIR /uc3
COPY --from=builder /build/uc3 .
EXPOSE 5003
CMD [ "node", "index.js" ]
