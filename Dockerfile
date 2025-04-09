FROM node:16.20.0-slim

WORKDIR /app

# Copy package files
COPY package.json ./
COPY api/package.json api/
COPY web/package.json web/
COPY docker/.env .

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Generate Prisma client
RUN cd api && npx prisma generate

# Build API
RUN cd api && npm run build

# Build Web
RUN cd web && npm run build

# Set environment variables
ENV NODE_ENV=production

# Expose port
EXPOSE 8080

# Start the application
CMD ["node", "api/dist/index.js"]
